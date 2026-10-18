import {
  backdropSource, compileLayerEffect, dualKawaseBlur, get, layerSource,
  loadShader, save, shaderStage, renderToIfDirty, stateSource, stateTexture,
} from "shoji_wm";

// All distances are framebuffer pixels. This pipeline knows only the alpha
// silhouette: no shape count, positions, or corner radii come from QuickShell.
export const ISLAND_GLASS_OPTIONS = {
  // Match Theme.glassAlpha in hyalo-shell; required to retain its edge AA.
  // Kept low so the silhouette adds no visible white/black tint.
  surfaceOpacity: 0.04,
  // macOS Liquid Glass: a slab with a rounded edge. Only a narrow band along
  // the rim bends the picture (strongly, like the edge of a lens); the middle
  // is flat and just frosted.
  rimWidth: 22,
  refraction: 16,
  chromaticShift: 1.2,
  // A bright, thin specular rim all around, strongest at the upper left.
  highlight: 0.7,
  highlightWidth: 1.5,
  // Light frosting: details behind stay recognisable, as in Apple's examples
  // (the clouds and the reflection behind its widgets and dock).
  blurRadius: 2,
  blurPasses: 2,
  blurMix: 1,
  // Vibrancy: what shows through the glass keeps (and slightly gains) its colour.
  saturation: 1.1,
  // Multiplies what shows through: 1 leaves its brightness alone; Apple's clear
  // glass lifts it only a touch.
  shade: 1.03,
  normalSmoothing: 3,
  edgeSoftness: 2,
  // A faint darker band just inside the rim gives the slab its thickness.
  bevelWidth: 8,
  bevelShadow: 0.12,
  // 0: glass, 1: mask, 2: distance, 3: surface gradient.
  debugView: 0,
};

export type IslandGlassOptions = typeof ISLAND_GLASS_OPTIONS;

/**
 * One compiled glass effect. Variants share the pipeline and differ only in
 * their options; `name` keeps each one's distance field separate.
 */
export function islandGlass(name: string, overrides: Partial<IslandGlassOptions> = {}) {
  const o: IslandGlassOptions = { ...ISLAND_GLASS_OPTIONS, ...overrides };
  const directionSmoothing = Math.max(o.normalSmoothing, o.rimWidth * 0.2);

  // Float local boundary offsets / signed distances retain subpixel precision.
  // Overwritten from the current mask each refresh; no temporal feedback.
  const distanceField = stateTexture(`${name}-distance-v2`, {
    format: "rgba16f", scale: 1, resize: "clear",
  });

  return compileLayerEffect({
    input: backdropSource(),
    // The surface is fixed-size and mostly transparent; its input mask follows
    // the silhouettes, so only that part (plus the smooth-min bulge where shapes
    // merge, theme.js surfacePad) is captured and processed.
    region: "input",
    outsets: 40,
    capturePadding: 64,
    alpha: "preserve",
    // A silhouette change affects an entire rim, not just the damaged pixel.
    invalidate: { kind: "on-source-damage-box", damagePadding: 64 },
    pipeline: [
      save("island-sharp"),
      dualKawaseBlur({ radius: o.blurRadius, passes: o.blurPasses }),
      save("island-soft"),
      //dualKawaseBlur({ radius: 3, passes: 2 }),
      save("island-edge-soft"),
      shaderStage(loadShader("./src/effect/island-mask.frag"), {
        textures: { layer_mask: layerSource() },
        uniforms: { surface_opacity: o.surfaceOpacity },
      }),
      save("island-mask"),
      // The distance field depends only on the layer's own silhouette, so it is
      // rebuilt only when the layer's content changes, not whenever the backdrop
      // underneath it does.
      renderToIfDirty(distanceField, {
        dependsOn: [layerSource()],
        // Already aligned to the padded backdrop. Direct layerSource here would
        // stretch the unpadded layer to the renderTo canvas.
        input: get("island-mask"),
        pipeline: [
          // Float-prefilter the silhouette before selecting boundary seeds.
          // The final clip still uses the original mask, so UI edges stay crisp.
          shaderStage(loadShader("./src/effect/island-smooth.frag"), {
            uniforms: { axis: [1, 0] as const, smoothing_px: 1 },
            textures: { field_input: get("island-mask") },
          }),
          save("island-seed-mask-x"),
          shaderStage(loadShader("./src/effect/island-smooth.frag"), {
            uniforms: { axis: [0, 1] as const, smoothing_px: 1 },
            textures: { field_input: get("island-seed-mask-x") },
          }),
          save("island-seed-mask"),
          shaderStage(loadShader("./src/effect/island-seed.frag"), {
            textures: { mask_input: get("island-seed-mask") },
          }),
          save("island-float-step"),
          ...[64, 32, 16, 8, 4, 2, 1, 1].flatMap((jump) => [
            shaderStage(loadShader("./src/effect/island-jump.frag"), {
              uniforms: { jump_px: jump },
              textures: { field_input: get("island-float-step") },
            }),
            save("island-float-step"),
          ]
          ),
          shaderStage(loadShader("./src/effect/island-height.frag"), {
            textures: { silhouette: get("island-seed-mask"), field_input: get("island-float-step") },
            uniforms: { distance_limit_px: 120 },
          }),
          save("island-float-step"),
          shaderStage(loadShader("./src/effect/island-smooth.frag"), {
            uniforms: { axis: [1, 0] as const, smoothing_px: o.normalSmoothing },
            textures: { field_input: get("island-float-step") },
          }),
          save("island-float-step"),
          shaderStage(loadShader("./src/effect/island-smooth.frag"), {
            uniforms: { axis: [0, 1] as const, smoothing_px: o.normalSmoothing },
            textures: { field_input: get("island-float-step") },
          }),
          save("island-float-step"),
          // The bend direction comes from a much smoother copy, which rounds it
          // around corners sharper than the rim.
          shaderStage(loadShader("./src/effect/island-smooth.frag"), {
            uniforms: { axis: [1, 0] as const, smoothing_px: directionSmoothing },
            textures: { field_input: get("island-float-step") },
          }),
          save("island-direction"),
          shaderStage(loadShader("./src/effect/island-smooth.frag"), {
            uniforms: { axis: [0, 1] as const, smoothing_px: directionSmoothing },
            textures: { field_input: get("island-direction") },
          }),
          save("island-direction"),
          // Where the shape is thinner than the rim, the lens flattens out at
          // its middle instead of creasing there.
          shaderStage(loadShader("./src/effect/island-ridge.frag"), {
            uniforms: { rim_width_px: o.rimWidth },
            textures: {
              field_input: get("island-float-step"),
              direction_input: get("island-direction"),
            },
          }),
          // renderToIfDirty() keeps this final float texture as the state without
          // copying it, so stateSource() below reads it in the same raw
          // multi-texture coordinate system.
        ],
      }),
      shaderStage(loadShader("./src/effect/island-refract.frag"), {
        textures: {
          sharp_scene: get("island-sharp"),
          soft_scene: get("island-soft"),
          edge_scene: get("island-edge-soft"),
          silhouette: get("island-mask"),
          distance_field: stateSource(distanceField),
        },
        uniforms: {
          rim_width_px: o.rimWidth,
          refraction_px: o.refraction,
          chromatic_shift_px: o.chromaticShift,
          highlight_strength: o.highlight,
          highlight_width_px: o.highlightWidth,
          debug_view: o.debugView,
          blur_mix: o.blurMix,
          edge_softness_px: o.edgeSoftness,
          bevel_width_px: o.bevelWidth,
          bevel_shadow: o.bevelShadow,
          saturation: o.saturation,
          shade: o.shade,
        },
      }),
    ],
  });
}

// Every hyalo-shell surface, light appearance.
export const ISLAND_GLASS = islandGlass("island");

// The dark appearance dims what is behind a little.
export const ISLAND_GLASS_DARK = islandGlass("island-dark", { shade: 0.85 });
