// The tint laid over every piece of liquid glass: window title bars and
// frames, and the shell's glass (dock, control center, launcher, OSD,
// notifications). The lock screen and the greeter draw their own glass with
// the same values: keep Theme.glassTintDark / glassTintLight in
// config/shell/common/Theme.qml equal to these.
export const GLASS_TINT = {
  dark: "#08080a59",
  light: "#f6f6f880",
};

/** `#rrggbbaa` as a straight-alpha vec4 for shaders. */
export function tintVec4(hex: string): [number, number, number, number] {
  const v = hex.replace("#", "");
  const c = (i: number) => parseInt(v.slice(i, i + 2), 16) / 255;
  return [c(0), c(2), c(4), v.length === 8 ? c(6) : 1];
}

// How bright or dark the backdrop under any piece of liquid glass may read,
// as the luma of a wide average of it. Over a white window the glass is
// pulled down to `ceiling` so it still separates from what is behind it; over
// a black one it is lifted to `floor`. In between the glass is untouched.
// The lock screen and the greeter use Theme.glassAmbientCeiling / Floor in
// config/shell/common/Theme.qml: keep those equal to these.
export const GLASS_AMBIENT = {
  ceiling: 0.86,
  floor: 0.08,
};
