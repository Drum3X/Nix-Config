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
    float ambientCeiling;  // Theme.glassAmbientCeiling (GLASS_AMBIENT)
    float ambientFloor;
};

layout(binding = 1) uniform sampler2D source;

float roundedBox(vec2 p, vec2 halfSize, float r) {
    vec2 q = abs(p) - halfSize + r;
    return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

vec3 sampleAt(vec2 px) {
    // Clamped to the backdrop, not to this item: clamping to the item
    // smeared its border pixels into streaks.
    vec2 uv = rect.xy + (px / size) * rect.zw;
    return texture(source, clamp(uv, 0.0, 1.0)).rgb;
}

// GLASS_AMBIENT in config/shojiwm/src/glass-tint.ts, as adaptToAmbient in
// island-refract.frag: darken the glass over a backdrop brighter than the
// ceiling, lift it over one darker than the floor. The ambient here is the
// average of the backdrop under the whole item.
vec3 adaptToAmbient(vec3 color, vec3 ambient) {
    float luma = dot(ambient, vec3(0.2126, 0.7152, 0.0722));
    if (luma > ambientCeiling)
        return color * (ambientCeiling / luma);
    if (luma < ambientFloor)
        return 1.0 - (1.0 - color) * ((1.0 - ambientFloor) / (1.0 - luma));
    return color;
}

vec3 ambientUnderItem() {
    vec3 sum = vec3(0.0);
    for (int y = 0; y < 3; y++)
        for (int x = 0; x < 3; x++)
            sum += sampleAt(size * (vec2(x, y) + 0.5) / 3.0);
    return sum / 9.0;
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
    // The rim never reaches past the centre line of a thin shape (a pill):
    // there the normal flips, and a bend still running would tear the
    // picture in two along the middle. The bend is kept within the rim too.
    float rim = min(rimWidth, min(halfSize.x, halfSize.y));
    float edge = clamp(1.0 + d / max(rim, 1.0), 0.0, 1.0);
    float bend = edge * edge * min(refraction, rim * 0.6);

    vec2 offset = -n * bend;
    vec3 color = vec3(sampleAt(px + offset * 1.06).r,
                      sampleAt(px + offset).g,
                      sampleAt(px + offset * 0.94).b);

    color = adaptToAmbient(color, ambientUnderItem());

    color = mix(color, tint.rgb / max(tint.a, 0.0001), tint.a);

    // Thin rim light, brighter where it faces the light (upper left).
    float rimBand = 1.0 - smoothstep(0.0, 1.6, -d);
    float facing = 0.55 + 0.45 * dot(n, normalize(vec2(-0.5, -1.0)));
    color += rimColor.rgb * rimBand * facing;

    fragColor = vec4(clamp(color, 0.0, 1.0), 1.0) * coverage * qt_Opacity;
}
