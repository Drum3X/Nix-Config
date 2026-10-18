uniform float dim;

// Hyalo: dims an unfocused window. Drawn in front of the window, a black
// veil masked by the window's own alpha (rounded corners and translucent
// parts stay as they are). `dim` is the veil's opacity, 0 for none.
vec4 shader_main(EffectContext effect) {
    float alpha = texture2D(tex, effect.texture_uv).a;
    return vec4(0.0, 0.0, 0.0, alpha * dim);
}
