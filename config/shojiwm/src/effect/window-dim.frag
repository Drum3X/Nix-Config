uniform float dim;
uniform float veil;

// Hyalo: dims an unfocused window. Drawn in front of the window, a grey
// veil masked by the window's own alpha (rounded corners and translucent
// parts stay as they are). `dim` is the veil's opacity, 0 for none; `veil`
// its grey level. A grey rather than black veil also flattens dark windows
// (VS Code), where black would change nothing: light parts darken, dark
// parts lift a little.
vec4 shader_main(EffectContext effect) {
    float a = texture2D(tex, effect.texture_uv).a * dim;
    return vec4(vec3(veil * a), a);
}
