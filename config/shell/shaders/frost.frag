#version 440
// Liquid glass for FrostGlass.qml: a rounded rectangle that refracts a blurred
// backdrop. Deep inside, the picture passes straight through under a tint;
// toward the rim it is pulled inward along the surface normal (a lens edge),
// split slightly by wavelength, and lit by a thin highlight.

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    vec4 rect;        // this item on the backdrop, in backdrop UV (x, y, w, h)
    vec2 size;        // item size in px
    float radius;
    float refraction;
    float rimWidth;
    vec4 tint;        // premultiplied
    vec4 rimColor;    // premultiplied
};

layout(binding = 1) uniform sampler2D source;

float roundedBox(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec3 sampleAt(vec2 px) {
    vec2 uv = rect.xy + clamp(px / size, 0.0, 1.0) * rect.zw;
    return texture(source, uv).rgb;
}

void main() {
    vec2 px = qt_TexCoord0 * size;
    vec2 halfSize = size * 0.5;
    vec2 p = px - halfSize;
    float r = min(radius, min(halfSize.x, halfSize.y));

    float d = roundedBox(p, halfSize, r);           // < 0 inside
    float aa = max(fwidth(d), 0.75);
    float coverage = clamp(0.5 - d / aa, 0.0, 1.0);
    if (coverage <= 0.0) {
        fragColor = vec4(0.0);
        return;
    }

    // Surface normal from the distance field.
    vec2 e = vec2(1.0, 0.0);
    vec2 n = vec2(roundedBox(p + e.xy, halfSize, r) - roundedBox(p - e.xy, halfSize, r),
                  roundedBox(p + e.yx, halfSize, r) - roundedBox(p - e.yx, halfSize, r));
    n = length(n) > 0.0001 ? normalize(n) : vec2(0.0);

    // 0 deep inside, 1 at the edge; squared so the bend is concentrated at the rim.
    float edge = clamp(1.0 + d / max(rimWidth, 1.0), 0.0, 1.0);
    float bend = edge * edge * refraction;

    vec2 offset = -n * bend;
    vec3 color = vec3(sampleAt(px + offset * 1.06).r,
                      sampleAt(px + offset).g,
                      sampleAt(px + offset * 0.94).b);

    // Vibrancy, as on macOS (and as in the compositor glass).
    float luma = dot(color, vec3(0.2126, 0.7152, 0.0722));
    color = clamp(mix(vec3(luma), color, 1.35), 0.0, 1.0);

    color = mix(color, tint.rgb / max(tint.a, 0.0001), tint.a);

    // Thin rim light, brighter where it faces the light (upper left).
    float rimBand = 1.0 - smoothstep(0.0, 1.6, -d);
    float facing = 0.55 + 0.45 * dot(n, normalize(vec2(-0.5, -1.0)));
    color += rimColor.rgb * rimBand * facing;

    fragColor = vec4(clamp(color, 0.0, 1.0), 1.0) * coverage * qt_Opacity;
}
