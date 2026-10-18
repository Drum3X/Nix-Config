// Reference : https://medium.com/@aghajari/liquid-glass-ios-effect-explanation-dabadd6414ae

uniform float glass_width_px;
uniform float glass_height_px;
// Negative: follow the shape ShojiWM reports (the frame's own corner
// radius, or the rounded clip around it, e.g. the window's corners).
uniform float glass_radius_px;
uniform float distortion_depth;
uniform float distortion_strength;
uniform float chromatic_shift_px;
uniform float glass_tint;
// Hyalo: the specular rim of the shell's glass (island-refract.frag), so window
// frames and the bar/dock catch the light the same way.
uniform float highlight_strength;
uniform float highlight_width_px;
// Hyalo: `tex` is a wide blur of the backdrop (its brightness around each
// point) and `scene` the lightly blurred backdrop the glass shows. See
// GLASS_AMBIENT in glass-tint.ts and adaptToAmbient in island-refract.frag.
uniform sampler2D scene;
uniform float ambient_ceiling;
uniform float ambient_floor;

float sdf(vec2 p, vec2 b, float r) {
    vec2 d = abs(p) - b + vec2(r);
    return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - r;
}

vec2 safeNormalize(vec2 value) {
    float scale = max(max(abs(value.x), abs(value.y)), 0.0001);
    vec2 scaled = value / scale;
    return scaled / max(length(scaled), 0.0001);
}

vec3 getTextureColorAt(EffectContext effect, vec2 content_coord) {
    vec2 sample_uv = clamp(
        effect_texture_uv_from_content_phy_px(effect, content_coord),
        vec2(0.0),
        vec2(1.0)
    );
    return texture2D(scene, sample_uv).rgb;
}

vec3 adaptToAmbient(vec3 color, vec3 ambient) {
    float luma = dot(ambient, vec3(0.2126, 0.7152, 0.0722));
    if (luma > ambient_ceiling)
        return color * (ambient_ceiling / luma);
    if (luma < ambient_floor)
        return 1.0 - (1.0 - color) * ((1.0 - ambient_floor) / (1.0 - luma));
    return color;
}

vec4 shader_main(EffectContext effect) {
    vec2 rect_size = effect.content_rect_phy_px.zw;
    vec2 fragCoord = effect_content_phy_px(effect);
    vec2 glassSize = vec2(
        glass_width_px > 0.0 ? glass_width_px : rect_size.x,
        glass_height_px > 0.0 ? glass_height_px : rect_size.y
    );
    vec2 glassCenter = rect_size * 0.5;
    vec2 glassCoord = fragCoord - glassCenter;

    float glassRadius = glass_radius_px;
    if (glassRadius < 0.0) {
        glassRadius = effect.frame_radius_phy_px.x > 0.0
            ? effect.frame_radius_phy_px.x
            : (effect.has_clip ? effect.clip_radius_phy_px.x : 0.0);
    }

    float size = max(min(glassSize.x, glassSize.y), 1.0);
    // Keep squared values inside mediump range. Some drivers evaluate length()
    // with 16-bit intermediates while others silently promote them.
    float sdfScale = max(max(glassSize.x, glassSize.y), 1.0);
    float inversedSDF = -sdf(
        glassCoord / sdfScale,
        glassSize * 0.5 / sdfScale,
        glassRadius / sdfScale
    ) * sdfScale / size;

    if (inversedSDF < 0.0) {
        return vec4(getTextureColorAt(effect, fragCoord), 1.0);
    }

    vec2 normalizedGlassCoord = safeNormalize(glassCoord);
    float distFromCenter = 1.0 - clamp(inversedSDF / max(distortion_depth, 0.0001), 0.0, 1.0);
    float distortion = 1.0 - sqrt(max(1.0 - pow(distFromCenter, 2.0), 0.0));
    vec2 offset = distortion * normalizedGlassCoord * glassSize * 0.5 * distortion_strength;
    vec2 glassColorCoord = fragCoord - offset;

    float edge = smoothstep(0.0, 0.02, inversedSDF);
    vec2 shift = normalizedGlassCoord * edge * chromatic_shift_px;
    vec3 glassColor = vec3(
        getTextureColorAt(effect, glassColorCoord - shift).r,
        getTextureColorAt(effect, glassColorCoord).g,
        getTextureColorAt(effect, glassColorCoord + shift).b
    );

    glassColor = adaptToAmbient(glassColor, texture2D(tex, effect.texture_uv).rgb);
    glassColor *= vec3(glass_tint);

    // Rim light from the upper left, fainter on the far side, as on the bar.
    float distancePx = inversedSDF * size;
    float light = dot(normalizedGlassCoord, normalize(vec2(-0.45, -0.89)));
    float glint = 0.12 + 0.88 * pow(max(light, 0.0), 1.5) + 0.5 * pow(max(-light, 0.0), 1.5);
    float band = exp(-distancePx / max(highlight_width_px, 0.5));
    float shine = clamp(highlight_strength * glint * band * 1.2, 0.0, 1.0);
    glassColor = 1.0 - (1.0 - glassColor) * (1.0 - shine * vec3(0.94, 0.97, 1.0));
    return vec4(glassColor, 1.0);
}
