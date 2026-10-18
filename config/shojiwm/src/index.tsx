import {
  AppIcon,
  Box,
  Button,
  ClientWindow,
  Image,
  ShaderEffect,
  Label,
  COMPOSITOR,
  WindowBorder,
  backdropSource,
  compileEffect,
  compileLayerEffect,
  dualKawaseBlur,
  type SSDStyle,
  type WaylandWindow,
  type WindowDecorationState,
  computed,
  signal,
  useState,
  shaderStage,
  loadShader,
  layerSource,
  ManagedWindow,
  read,
  type DisplayConfigDraft,
  compilePopupEffect,
  popupSource,
  Popup,
  type ReadonlySignal,
  DefaultComposition,
} from "shoji_wm";
import type { CompositionRenderable, ManagedWindowRect } from "shoji_wm/types";
import { createIpcServer } from "shoji_wm/ipc";
import {
  HybridWindowManager,
  TITLEBAR_HEIGHT,
  WINDOW_BORDER_PX,
  WINDOW_STATE_FULLSCREEN,
  WINDOW_STATE_MINIMIZED,
  WINDOW_STATE_MINIMIZE_VISUAL_IDLE,
  WINDOW_STATE_TILE_DRAGGING,
  WINDOW_STATE_TILE_REORDERING,
  WINDOW_STATE_TILED,
  WINDOW_STATE_WORKSPACE_TILED,
  WINDOW_STATE_VISIBLE_OUTPUTS,
  WINDOW_STATE_RECT,
  WINDOW_STATE_WORKSPACE_VISIBLE,
  WINDOW_STATE_WORKSPACE_OFFSET_Y,
  WINDOW_STATE_WORKSPACE_OPACITY,
} from "./window-manager";
import { ISLAND_GLASS } from "./effect/island-glass";
import { createFlip3D } from "./flip-3d";
import { createWindowGrid } from "./window-grid";
import { installDragAndDrop } from "./drag-and-drop";
import type { TitlebarButton } from "./window-switcher";

COMPOSITOR.env.apply({
  QT_QPA_PLATFORM: "wayland;xcb",
  QT_QPA_PLATFORMTHEME: "qt6ct",
  ELECTRON_OZONE_PLATFORM_HINT: "wayland",
  NIXOS_OZONE_WL: "1",
});
COMPOSITOR.env.publish();

COMPOSITOR.cursor.configure({
  theme: "Bibata-Modern-Classic",
  size: 24,
});

COMPOSITOR.process.once("GTK-CSD-control-buttons", {
  command: "gsettings set org.gnome.desktop.wm.preferences button-layout 'close,minimize,maximize:'",
  runPolicy: "once-per-session",
});

COMPOSITOR.window.decoration.configure((_window, context) => {
  return { mode: context.clientPreference ?? "server" };
});

// enable triple buffer mode for massive performance
COMPOSITOR.rendering.framePacing = "throughput";

/**
 * Windows 7 style: on server-decorated windows the glass frame goes all the
 * way round the client, not just across the title bar. Kept thin. `naturalRootRect` and the window
 * compositions must agree on it. Declared before the window manager, which
 * calls naturalRootRect.
 */
const GLASS_FRAME_PX = 4;
/** The client inside the glass frame is rounded too. */
const CLIENT_RADIUS_PX = 8;

const HYBRID_WINDOW_MANAGER = new HybridWindowManager(naturalRootRect);

// Window switcher (Super+Tab): "flip-3d" stacks the windows in 3D
// (./flip-3d.tsx), "grid" lays them out side by side (./window-grid.tsx).
const WINDOW_SWITCHER_STYLE = "flip-3d" as "flip-3d" | "grid";
const WINDOW_SWITCHER = (
  WINDOW_SWITCHER_STYLE === "grid" ? createWindowGrid : createFlip3D
)({
  windowManager: HYBRID_WINDOW_MANAGER,
  stackOrder: (window) =>
    window.state[WINDOW_STATE_FULLSCREEN]()
      ? FULLSCREEN_Z_INDEX
      : windowZIndex(window),
  // The grid's selected card: its title bar buttons work.
  titlebarButtonAt,
});

// Drag and drop: the dragged image on a card with the action and the kind of
// data, flying back when a drop is refused (./drag-and-drop.tsx).
installDragAndDrop();
COMPOSITOR.rendering.composition = (output) =>
  WINDOW_SWITCHER.compose(output) ?? <DefaultComposition />;

// Window backdrop effects end with this stage so they can fade back in after
// the switcher closes.
const backdropFade = () =>
  shaderStage(loadShader("./src/effect/backdrop-fade.frag"), {
    uniforms: { strength: WINDOW_SWITCHER.backdropStrength },
  });
const HOT_RELOAD_WINDOW_MANAGER_STATE = "config.hybrid-window-manager";
const FULLSCREEN_Z_INDEX = 2_000_000_000;
const FLOATING_WINDOW_Z_INDEX_BASE = 1_500_000_000;
const WINDOW_STACK_Z_INDEX_RANGE = 100_000_000;
const FOCUSED_TILED_WINDOW_Z_INDEX = 1_000_000_000;
const REORDERING_TILED_WINDOW_Z_INDEX = -2_000_000_000;

/** Where a (non-fullscreen) window sits in the stack; higher is on top. */
function windowZIndex(window: WaylandWindow): number {
  const stackZIndex = HYBRID_WINDOW_MANAGER.getWindowZIndex(window)();
  if (!window.state[WINDOW_STATE_WORKSPACE_TILED]()) {
    return stackZIndex;
  }
  const stackOffset = Math.max(
    -WINDOW_STACK_Z_INDEX_RANGE,
    Math.min(WINDOW_STACK_Z_INDEX_RANGE, stackZIndex),
  );
  if (!window.state[WINDOW_STATE_TILED]()) {
    return FLOATING_WINDOW_Z_INDEX_BASE + stackOffset;
  }
  if (window.state[WINDOW_STATE_TILE_REORDERING]()) {
    return REORDERING_TILED_WINDOW_Z_INDEX;
  }
  return window.isFocused() ? FOCUSED_TILED_WINDOW_Z_INDEX : stackOffset;
}

COMPOSITOR.onDisable((event) => {
  if (event.isReloading) {
    const snapshot = HYBRID_WINDOW_MANAGER.snapshot();
    event.persist(HOT_RELOAD_WINDOW_MANAGER_STATE, snapshot);
  }
  HYBRID_WINDOW_MANAGER.dispose();
});

COMPOSITOR.onEnable((event) => {
  if (event.isReloading) {
    const snapshot = event.restore<
      ReturnType<typeof HYBRID_WINDOW_MANAGER.snapshot>
    >(HOT_RELOAD_WINDOW_MANAGER_STATE);
    if (snapshot) {
      HYBRID_WINDOW_MANAGER.restore(snapshot);
    }
  }
});

// ---------------------------------------------------------------------------
// External IPC: expose the workspace layout to clients such as the bar.
//   workspaces.get           -> WorkspacesView                     (request/response)
//   workspaces.switch        { direction: -1 | 1 }                 (command)
//   workspaces.activate      { monitor: string, index: number }    (command)
//   workspaces.toggleTiling  { monitor?: string }                  (command)
//   workspaces.changed       -> WorkspacesView                     (broadcast)
//   windows.activate         { windowId: string }                  (command)
//   dock.proximity           { monitor: string, inside: bool }    (broadcast)
// ---------------------------------------------------------------------------
const WORKSPACE_IPC = createIpcServer();
let lastWorkspacesJson = "";
let workspaceBroadcastQueued = false;

function broadcastWorkspaces() {
  const view = HYBRID_WINDOW_MANAGER.viewForIpc();
  const json = JSON.stringify(view);
  if (json === lastWorkspacesJson) {
    return;
  }
  lastWorkspacesJson = json;
  WORKSPACE_IPC.broadcast("workspaces.changed", view);
}

function reconfigureProtocolWorkspaces() {
  COMPOSITOR.workspace.reconfigure();
}

// Coalesce many state mutations within one tick into a single diffed broadcast.
function scheduleWorkspaceBroadcast() {
  // Protocol state must be staged before the current runtime response is
  // written; otherwise key bindings/Waybar activations only reach external
  // bars on a later, unrelated runtime request.
  reconfigureProtocolWorkspaces();
  if (workspaceBroadcastQueued) {
    return;
  }
  workspaceBroadcastQueued = true;
  void Promise.resolve().then(() => {
    workspaceBroadcastQueued = false;
    broadcastWorkspaces();
  });
}

COMPOSITOR.workspace.configure(() => {
  const view = HYBRID_WINDOW_MANAGER.viewForIpc();
  return {
    groups: view.monitors.map((monitor) => ({
      id: monitor.name,
      outputs: [monitor.name],
      workspaces: monitor.workspaces.map((workspace) => ({
        id: `${monitor.name}:${workspace.index}`,
        name: String(workspace.index),
        coordinates: [Math.max(0, workspace.index - 1)],
        active: workspace.active,
        hidden: !workspace.active && workspace.windowCount === 0,
      })),
    })),
  };
});

COMPOSITOR.workspace.event.onActivate((event) => {
  const [monitor, rawIndex] = event.workspaceId.split(":");
  const index = Number(rawIndex);
  if (!monitor || !Number.isInteger(index) || index < 1) {
    return;
  }
  HYBRID_WINDOW_MANAGER.activate(monitor, index);
  scheduleWorkspaceBroadcast();
});

WORKSPACE_IPC.handle("workspaces.get", () =>
  HYBRID_WINDOW_MANAGER.viewForIpc(),
);
WORKSPACE_IPC.handle("workspaces.switch", (params) => {
  const direction = (params as { direction?: number } | undefined)?.direction;
  HYBRID_WINDOW_MANAGER.switchWorkspace(direction === -1 ? -1 : 1);
  scheduleWorkspaceBroadcast();
});
WORKSPACE_IPC.handle("workspaces.activate", (params) => {
  const request = params as { monitor?: string; index?: number } | undefined;
  if (request?.monitor && typeof request.index === "number") {
    HYBRID_WINDOW_MANAGER.activate(request.monitor, request.index);
    scheduleWorkspaceBroadcast();
  }
});
WORKSPACE_IPC.handle("workspaces.toggleTiling", (params) => {
  const monitor = (params as { monitor?: string } | undefined)?.monitor;
  if (monitor) {
    HYBRID_WINDOW_MANAGER.toggleWorkspaceTilingForMonitor(monitor);
  } else {
    HYBRID_WINDOW_MANAGER.toggleCurrentWorkspaceTiling();
  }
  scheduleWorkspaceBroadcast();
});
WORKSPACE_IPC.handle("windows.activate", (params) => {
  const windowId = (params as { windowId?: string } | undefined)?.windowId;
  if (typeof windowId === "string") {
    HYBRID_WINDOW_MANAGER.activateWindowById(windowId);
    scheduleWorkspaceBroadcast();
  }
});

// ---------------------------------------------------------------------------
// Dock proximity: watch the pointer and broadcast enter/leave for the bottom
// strip of each monitor. The bar uses this in place of a layer-shell trigger
// surface (which would otherwise capture clicks meant for the windows below).
// ---------------------------------------------------------------------------
// Two thresholds with hysteresis:
//   - SHOW: pointer must be in the bottom 10px to trigger reveal
//   - HIDE: once visible, pointer must leave the bottom 120px to dismiss
// This gives a precise "reach for the dock" trigger while keeping the dock
// stable once the user is interacting with it (so brushing the cursor a few
// dozen pixels above the dock body does not flicker it away).
const DOCK_SHOW_ZONE_PX = 10;
const DOCK_HIDE_ZONE_PX = 120;
const dockProximityByMonitor = new Map<string, boolean>();

function pointerInBottomStrip(
  monitor: string,
  pointerX: number,
  pointerY: number,
  stripPx: number,
): boolean {
  const output = COMPOSITOR.output.get(monitor);
  if (!output || !output.resolution) {
    return false;
  }
  const width = output.resolution.width / output.scale;
  const height = output.resolution.height / output.scale;
  const left = output.position.x;
  const top = output.position.y;
  const right = left + width;
  const bottom = top + height;
  return (
    pointerX >= left &&
    pointerX < right &&
    pointerY >= bottom - stripPx &&
    pointerY < bottom
  );
}

function nextDockProximity(
  monitor: string,
  pointerX: number,
  pointerY: number,
  onTrackedMonitor: boolean,
): boolean {
  if (!onTrackedMonitor) return false;
  const wasInside = dockProximityByMonitor.get(monitor) === true;
  // While outside, only the narrow show-zone counts (10px).
  // While inside, the wide hide-zone keeps it open (120px).
  return pointerInBottomStrip(
    monitor,
    pointerX,
    pointerY,
    wasInside ? DOCK_HIDE_ZONE_PX : DOCK_SHOW_ZONE_PX,
  );
}

function updateDockProximity(monitor: string, inside: boolean) {
  if (dockProximityByMonitor.get(monitor) === inside) {
    return;
  }
  dockProximityByMonitor.set(monitor, inside);
  WORKSPACE_IPC.broadcast("dock.proximity", { monitor, inside });
}

// Snap-zone preview: broadcast the active snap rect (floating edge zones, or the
// opened tiling slot) to the bar, which renders the rounded preview overlay.
//   snap.preview  { monitor, rect: {x,y,w,h} | null, kind: "floating"|"tiling" }
let lastSnapJson = "";
HYBRID_WINDOW_MANAGER.setSnapPreviewBroadcaster((preview) => {
  const json = JSON.stringify(preview);
  if (json === lastSnapJson) {
    return;
  }
  lastSnapJson = json;
  WORKSPACE_IPC.broadcast("snap.preview", preview);
});

HYBRID_WINDOW_MANAGER.setWorkspaceChangeBroadcaster(() => {
  scheduleWorkspaceBroadcast();
});

COMPOSITOR.onDisable(() => {
  WORKSPACE_IPC.close();
});

// ---------------------------------------------------------------------------
// Hyalo: session, shell and key bindings.
//
// The shell is hyalo-shell (Quickshell, config/shell in the flake). Its IPC
// targets are reached through the `hyalo-shell ipc call <target> <fn>` wrapper:
//   launcher   toggleOn <screen> | clipboardOn <screen>
//   session    lock
//   control    toggle
//   brightness step <percent>
// ---------------------------------------------------------------------------
const SHELL = "hyalo-shell";
const TERMINAL = "ghostty";
const BROWSER = "vivaldi";
const FILES = "nautilus";

const spawn = (command: string | string[]) => () => {
  COMPOSITOR.process.spawn({ command });
};
const shellCall = (...args: string[]) => {
  COMPOSITOR.process.spawn({ command: [SHELL, "ipc", "call", ...args] });
};

// Whether the shell shows its dark palette. The shell sends `theme.set` on
// this socket whenever darkman switches, and again after every reconnect
// (which includes a config reload), so the decorations follow it.
const [themeDark, setThemeDark] = signal(false);
WORKSPACE_IPC.handle("theme.set", (params) => {
  setThemeDark((params as { mode?: string } | undefined)?.mode === "dark");
});

// The active keyboard layout, for the bar's layout indicator.
//   keyboard.get     -> { index, name }   (request/response)
//   keyboard.layout  -> { index, name }   (broadcast)
let keyboardLayout = { index: 0, name: "" };
COMPOSITOR.event.onKeyboardLayoutChange((event) => {
  keyboardLayout = { index: event.index, name: event.name };
  WORKSPACE_IPC.broadcast("keyboard.layout", keyboardLayout);
});
WORKSPACE_IPC.handle("keyboard.get", () => keyboardLayout);

// The shell turns the screens off after a long idle (and on again on input).
//   output.power  { mode: "on" | "off" }   (command)
WORKSPACE_IPC.handle("output.power", (params) => {
  const mode = (params as { mode?: string } | undefined)?.mode;
  if (mode === "on" || mode === "off") {
    COMPOSITOR.output.setPower(mode, { wakeOnInput: true });
  }
});

// Hand the Wayland environment to systemd/D-Bus activated services (portals,
// darkman, polkit agent) and start everything bound to graphical-session.target.
COMPOSITOR.process.once("session-target", {
  command:
    "dbus-update-activation-environment --systemd --all && systemctl --user start hyalo-session.target",
  runPolicy: "once-per-session",
});

// The shell: bar, dock, launcher, notifications, OSD, lock screen, wallpaper.
COMPOSITOR.process.service("shell", {
  command: [SHELL],
  restart: "on-failure",
});

// cliphist clipboard history watchers. Text and image need separate watchers;
// run as services so they are restarted if they ever exit.
COMPOSITOR.process.service("cliphist-text", {
  command: ["wl-paste", "--type", "text", "--watch", "cliphist", "store"],
  restart: "on-exit",
});
COMPOSITOR.process.service("cliphist-image", {
  command: ["wl-paste", "--type", "image", "--watch", "cliphist", "store"],
  restart: "on-exit",
});

// Applications.
COMPOSITOR.key.bind("terminal", "Super+Return", spawn([TERMINAL]));
COMPOSITOR.key.bind("terminal-alt", "Super+T", spawn([TERMINAL]));
COMPOSITOR.key.bind("browser", "Super+Q", spawn([BROWSER]));
COMPOSITOR.key.bind("files", "Super+E", spawn([FILES]));

// Shell panels, on the monitor under the cursor.
function toggleLauncher() {
  shellCall("launcher", "toggleOn", HYBRID_WINDOW_MANAGER.getCurrentMonitorName());
}
COMPOSITOR.key.bind("launcher", "Super+A", toggleLauncher);
COMPOSITOR.key.bind("launcher-space", "Super+Space", toggleLauncher);
// Super tap: fires on a quick release (within 300 ms) with no other key/button pressed in between.
COMPOSITOR.key.bind("launcher-tap", "Super", toggleLauncher, {
  on: "release",
  within: 300,
});
COMPOSITOR.key.bind("clipboard", "Super+V", () => {
  shellCall("launcher", "clipboardOn", HYBRID_WINDOW_MANAGER.getCurrentMonitorName());
});
COMPOSITOR.key.bind("control-center", "Super+N", () => {
  shellCall("control", "toggle");
});
// No monitor argument: a lock covers every screen, and the shell exposes no
// unlock over the same socket.
COMPOSITOR.key.bind("lock", "Super+L", () => {
  shellCall("session", "lock");
});

// Screenshots: a region or the monitor under the cursor, opened in swappy to
// annotate, copy or save.
const SCREENSHOT_REGION = `grim -g "$(slurp -d)" - | swappy -f -`;
COMPOSITOR.key.bind("screenshot-region", "Print", spawn(SCREENSHOT_REGION));
COMPOSITOR.key.bind("screenshot-region-alt", "Super+Shift+S", spawn(SCREENSHOT_REGION));
COMPOSITOR.key.bind("screenshot-output", "Shift+Print", () => {
  const monitor = HYBRID_WINDOW_MANAGER.getCurrentMonitorName();
  COMPOSITOR.process.spawn({ command: `grim -o "${monitor}" - | swappy -f -` });
});

// Media and hardware keys. The shell's OSD follows PipeWire on its own;
// brightness goes through the shell so it can show the change.
COMPOSITOR.key.bind("volume-up", "XF86AudioRaiseVolume", spawn("wpctl set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+"));
COMPOSITOR.key.bind("volume-down", "XF86AudioLowerVolume", spawn("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"));
COMPOSITOR.key.bind("volume-mute", "XF86AudioMute", spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"));
COMPOSITOR.key.bind("mic-mute", "XF86AudioMicMute", spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"));
COMPOSITOR.key.bind("play", "XF86AudioPlay", spawn("playerctl play-pause"));
COMPOSITOR.key.bind("pause", "XF86AudioPause", spawn("playerctl play-pause"));
COMPOSITOR.key.bind("next", "XF86AudioNext", spawn("playerctl next"));
COMPOSITOR.key.bind("prev", "XF86AudioPrev", spawn("playerctl previous"));
COMPOSITOR.key.bind("brightness-up", "XF86MonBrightnessUp", () => shellCall("brightness", "step", "5"));
COMPOSITOR.key.bind("brightness-down", "XF86MonBrightnessDown", () => shellCall("brightness", "step", "-5"));
COMPOSITOR.key.bind("monitors-off", "Super+Shift+P", () => {
  COMPOSITOR.output.setPower("off", { wakeOnInput: true });
});

// Windows.
COMPOSITOR.key.bind("close-focused-window", "Super+D", () => {
  HYBRID_WINDOW_MANAGER.closeFocusedWindow();
});
COMPOSITOR.key.bind("toggle-focused-window-maximize", "Super+F", () => {
  HYBRID_WINDOW_MANAGER.toggleFocusedWindowMaximize();
});
COMPOSITOR.key.bind("toggle-focused-window-maximize-alt", "Super+M", () => {
  HYBRID_WINDOW_MANAGER.toggleFocusedWindowMaximize();
});
COMPOSITOR.key.bind("toggle-focused-window-fullscreen", "Super+Shift+F", () => {
  HYBRID_WINDOW_MANAGER.toggleFocusedWindowFullscreen();
});
// Workspaces float by default; this tiles the current one (and back).
COMPOSITOR.key.bind("toggle-tiling-mode", "Super+S", () => {
  HYBRID_WINDOW_MANAGER.toggleCurrentWorkspaceTiling();
  scheduleWorkspaceBroadcast();
});
COMPOSITOR.key.bind("window-switcher", "Super+Tab", () => {
  WINDOW_SWITCHER.open(HYBRID_WINDOW_MANAGER.getCurrentMonitorName());
});
COMPOSITOR.key.bind("tile-focus-left-quick", "Super+Left", () => {
  HYBRID_WINDOW_MANAGER.focusTile(-1);
});
COMPOSITOR.key.bind("tile-focus-right-quick", "Super+Right", () => {
  HYBRID_WINDOW_MANAGER.focusTile(1);
});
COMPOSITOR.key.bind("tile-focus-left", "Super+Ctrl+Left", () => {
  HYBRID_WINDOW_MANAGER.focusTile(-1);
});
COMPOSITOR.key.bind("tile-focus-right", "Super+Ctrl+Right", () => {
  HYBRID_WINDOW_MANAGER.focusTile(1);
});
COMPOSITOR.key.bind("tile-move-left", "Super+Shift+Left", () => {
  HYBRID_WINDOW_MANAGER.moveFocusedTile(-1);
  scheduleWorkspaceBroadcast();
});
COMPOSITOR.key.bind("tile-move-right", "Super+Shift+Right", () => {
  HYBRID_WINDOW_MANAGER.moveFocusedTile(1);
  scheduleWorkspaceBroadcast();
});
COMPOSITOR.key.bind("window-move-workspace-prev", "Super+Shift+Up", () => {
  HYBRID_WINDOW_MANAGER.moveFocusedWindowToWorkspace(-1);
  scheduleWorkspaceBroadcast();
});
COMPOSITOR.key.bind("window-move-workspace-next", "Super+Shift+Down", () => {
  HYBRID_WINDOW_MANAGER.moveFocusedWindowToWorkspace(1);
  scheduleWorkspaceBroadcast();
});

// Workspaces: Super+N goes there, Super+Ctrl+N takes the focused window along.
for (let index = 1; index <= 9; index++) {
  COMPOSITOR.key.bind(`workspace-${index}`, `Super+${index}`, () => {
    HYBRID_WINDOW_MANAGER.activate(HYBRID_WINDOW_MANAGER.getCurrentMonitorName(), index);
    scheduleWorkspaceBroadcast();
  });
  COMPOSITOR.key.bind(`window-to-workspace-${index}`, `Super+Ctrl+${index}`, () => {
    HYBRID_WINDOW_MANAGER.moveFocusedWindowToWorkspaceIndex(index);
    scheduleWorkspaceBroadcast();
  });
}
const workspacePrev = () => {
  HYBRID_WINDOW_MANAGER.switchWorkspace(-1);
  scheduleWorkspaceBroadcast();
};
const workspaceNext = () => {
  HYBRID_WINDOW_MANAGER.switchWorkspace(1);
  scheduleWorkspaceBroadcast();
};
COMPOSITOR.key.bind("workspace-prev", "Super+Ctrl+Up", workspacePrev);
COMPOSITOR.key.bind("workspace-next", "Super+Ctrl+Down", workspaceNext);
COMPOSITOR.key.bind("workspace-prev-wheel", "Super+Ctrl+WheelScrollUp", workspacePrev);
COMPOSITOR.key.bind("workspace-next-wheel", "Super+Ctrl+WheelScrollDown", workspaceNext);

// Debugging.
let fpsCounter = false;
COMPOSITOR.key.bind("fps", "Super+Alt+F", () => {
  fpsCounter = !fpsCounter;
  COMPOSITOR.debug.fpsCounter = fpsCounter;
});

let profileEnabled = false;
COMPOSITOR.key.bind("profile", "Super+Alt+T", () => {
  profileEnabled = !profileEnabled;
  COMPOSITOR.debug.enableProfile(profileEnabled);
});

COMPOSITOR.output.configure((context) => {
  const display: DisplayConfigDraft = {};

  // Every monitor extends the desktop at its preferred mode, unscaled.
  for (const output of context.connected) {
    if (output.name) {
      display[output.name] = {
        mode: "extend",
        resolution: "best",
        position: "auto",
        scale: 1,
      };
    }
  }

  // The Nitro's own panel: 1920x1080, at its highest refresh rate (144 Hz).
  display["eDP-1"] = {
    mode: "extend",
    resolution: { width: 1920, height: 1080 },
    position: { x: 0, y: 0 },
    scale: 1,
    transform: "normal",
    hdr: false,
  };

  return display;
});

COMPOSITOR.input.configure((input, _context) => {
  input.global = {
    touchpad: {
      tapToClick: true,
      naturalScroll: true,
      scrollMethod: "twoFinger",
      disableWhileTyping: true,
      scrollFactor: 0.5,
      pointerAccel: 0.4,
    },
    pointer: {
      pointerAccel: 0.0,
      accelProfile: "flat",
      motionSpace: "logical",
    },
    keyboard: {
      // Turkish Q first; Alt+Shift switches to US.
      layout: "tr,us",
      options: "grp:alt_shift_toggle",
      repeatRate: 40,
      repeatDelay: 300,
    },
  };
});

HYBRID_WINDOW_MANAGER.configureWorkspaceGestureSpeed({
  workspaceScrollFactor: 1.5,
  workspaceScrollKineticFactor: 1,
  workspaceSwitchFactor: 1,
  workspaceSwitchVelocityFactor: 1,
  // At or below this scroll speed (logical px/s) the workspace scroll
  // catches on tile snap positions (fully-on-screen edges; center for
  // maximized tiles). 0 disables snapping.
  workspaceScrollSnapMaxVelocity: 600,
  // Finger travel (logical px) needed to break out of a caught position.
  workspaceScrollSnapBreakoutPx: 48,
});

// Blur behind the regions clients ask for (ext-background-effect). Off while
// the window switcher is shown, then faded back in like the window backdrops.
const BACKGROUND_BLUR = compileEffect({
  input: backdropSource(),
  capturePadding: 24,
  invalidate: { kind: "on-source-damage-box", damagePadding: 8 },
  alpha: "preserve",
  // Hyalo: the same blur as the window frames and the bar (radius 2, one pass).
  pipeline: [dualKawaseBlur({ radius: 2, passes: 1 }), backdropFade()],
});
COMPOSITOR.effect.background_effect = computed(() =>
  WINDOW_SWITCHER.blurSuspended() ? null : BACKGROUND_BLUR,
);

const LAYER_BLUR_MASK = compileLayerEffect({
  input: backdropSource(),
  capturePadding: 24,
  invalidate: { kind: "on-source-damage-box", damagePadding: 8 },
  // The mask stage intentionally outputs transparency (the blur is clipped
  // to the layer's own alpha), so the pipeline's alpha must survive the
  // finish/display passes instead of being forced opaque.
  alpha: "preserve",
  pipeline: [
    dualKawaseBlur({ radius: 4, passes: 2 }),
    shaderStage(loadShader("./src/effect/layer-blur-mask.frag"), {
      textures: {
        layer_mask: layerSource(),
      },
      uniforms: {
        opacity_threshold: 0.25,
        mask_feather: 0.04,
      },
    }),
  ],
});

COMPOSITOR.effect.layer = (layer) => {
  const namespace = layer.namespace();
  // hyalo-shell's surfaces draw only a faint silhouette (Theme.glassAlpha ==
  // ISLAND_GLASS_OPTIONS.surfaceOpacity) and let the compositor recover the
  // shape from it and refract what is behind.
  if (namespace?.startsWith("hyalo-")) {
    return { behind: ISLAND_GLASS };
  }
  // The wallpaper, and anything else that wants no glass at all.
  if (namespace === "no_blur") {
    return {};
  }

  return {
    behind: LAYER_BLUR_MASK,
  };
};

const POPUP_BLUR = compilePopupEffect({
  input: backdropSource(),
  capturePadding: 4 * 2 * 2 + 24 + 32,
  invalidate: { kind: "on-source-damage-box", damagePadding: 8 },
  // The mask stage intentionally outputs transparency (the blur is clipped
  // to the layer's own alpha), so the pipeline's alpha must survive the
  // finish/display passes instead of being forced opaque.
  alpha: "preserve",
  pipeline: [
    dualKawaseBlur({ radius: 4, passes: 2 }),
    shaderStage(loadShader("./src/effect/layer-blur-mask.frag"), {
      textures: {
        layer_mask: popupSource(),
      },
      uniforms: {
        opacity_threshold: 0.25,
        mask_feather: 0.04,
      },
    }),
  ],
});

COMPOSITOR.effect.popup = (popup) => {
  if (popup.parentKind === "window") {
    return {};
  }

  return {
    behind: POPUP_BLUR,
  };
};

// Chromium-family clients repaint their CSD shadow margins as transparent
// black — while still declaring the whole surface opaque — the moment they
// send set_minimized, assuming the surface will never be shown again. Honoring
// that declaration skips blending and paints the margins as a solid black
// ring during the minimize animation.
const isChromiumFamily = (appId: string): boolean => {
  const id = appId.toLowerCase();
  return (
    id.includes("chrome") || id.includes("chromium") || id.includes("vivaldi") || id.includes("electron")
  );
};

// GTK3 tooltips (waybar) declare their whole rect opaque despite transparent
// rounded corners, which paints the corners as a solid fill and culls the
// behind-blur. Ignore the declaration for layer-shell popups.
COMPOSITOR.rendering.surfacePolicy = (surface) => {
  if (surface.kind === "popup" && surface.parentKind === "layer") {
    return { opaqueRegion: "ignore" };
  }
  if (surface.kind === "toplevel") {
    const window = surface.window;
    // Minimized only: the restore animation fades in from opacity 0, so the
    // few frames where a stale black-margin buffer could still be on screen
    // after unminimize are effectively invisible.
    if (
      isChromiumFamily(window.appId() ?? "") &&
      (window.state[WINDOW_STATE_MINIMIZED]() ||
        window.state[WINDOW_STATE_MINIMIZE_VISUAL_IDLE]())
    ) {
      return { opaqueRegion: "ignore" };
    }
  }
  return null;
};

COMPOSITOR.event.onOpen((window) => {
  HYBRID_WINDOW_MANAGER.onOpen(window);
});

COMPOSITOR.event.onInitialConfigure((window) => {
  HYBRID_WINDOW_MANAGER.onInitialConfigure(window);
});

COMPOSITOR.event.onFirstCommit((window) => {
  HYBRID_WINDOW_MANAGER.onFirstCommit(window);
  scheduleWorkspaceBroadcast();
});

COMPOSITOR.event.onStartClose((window) => {
  HYBRID_WINDOW_MANAGER.onStartClose(window);
  scheduleWorkspaceBroadcast();
});

COMPOSITOR.event.onClose((window) => {
  HYBRID_WINDOW_MANAGER.onClose(window);
  scheduleWorkspaceBroadcast();
});

COMPOSITOR.event.onFocus((window, focused) => {
  HYBRID_WINDOW_MANAGER.onFocus(window, focused);
  if (focused) {
    HYBRID_WINDOW_MANAGER.recordFocus(window.id);
    scheduleWorkspaceBroadcast();
  }
});

COMPOSITOR.event.onPointerMove((event) => {
  HYBRID_WINDOW_MANAGER.onPointerMove(event);

  // Dock proximity: update only the monitor the pointer is currently on,
  // and emit "leave" for other monitors that were previously inside. The
  // narrow/wide threshold is hysteretic per current state.
  const pointerX = event.position.x;
  const pointerY = event.position.y;
  for (const monitor of COMPOSITOR.output.list) {
    const inside = nextDockProximity(
      monitor,
      pointerX,
      pointerY,
      monitor === event.outputName,
    );
    updateDockProximity(monitor, inside);
  }
});

COMPOSITOR.event.onGestureSwipe((event) => {
  HYBRID_WINDOW_MANAGER.onGestureSwipe(event);
  scheduleWorkspaceBroadcast();
});

COMPOSITOR.event.onOutputChange((event) => {
  HYBRID_WINDOW_MANAGER.onOutputChange(event);
  scheduleWorkspaceBroadcast();
});

COMPOSITOR.event.onCreateLayer(() => {
  HYBRID_WINDOW_MANAGER.refreshUsableAreaLayouts();
});

COMPOSITOR.event.onUpdateLayer(() => {
  HYBRID_WINDOW_MANAGER.refreshUsableAreaLayouts();
});

COMPOSITOR.event.onDestroyLayer(() => {
  HYBRID_WINDOW_MANAGER.refreshUsableAreaLayouts();
});

COMPOSITOR.event.onWindowResize((event) => {
  HYBRID_WINDOW_MANAGER.onWindowResize(event);
});

COMPOSITOR.pointer.bindWindowMoveModifier("Super");
COMPOSITOR.pointer.bindWindowResizeModifier("Super");
COMPOSITOR.cursor.bindAppLockIgnoreModifier("Super");

COMPOSITOR.event.onWindowMove((event) => {
  HYBRID_WINDOW_MANAGER.onWindowMove(event);
});

COMPOSITOR.event.onWindowMaximizeRequest((event) => {
  HYBRID_WINDOW_MANAGER.onWindowMaximizeRequest(event);
});

COMPOSITOR.event.onWindowMinimizeRequest((event) => {
  HYBRID_WINDOW_MANAGER.onWindowMinimizeRequest(event);
});

COMPOSITOR.event.onWindowFullscreenRequest((event) => {
  HYBRID_WINDOW_MANAGER.onWindowFullscreenRequest(event);
});

COMPOSITOR.event.onWindowActivateRequest((event) => {
  HYBRID_WINDOW_MANAGER.onWindowActivateRequest(event);
  scheduleWorkspaceBroadcast();
});

function usesClientDecoration(decoration: WindowDecorationState): boolean {
  return (
    decoration.mode === "client" &&
    !(
      decoration.clientPreference === "server" &&
      decoration.configuredMode === "server"
    )
  );
}

// Must match the frame the composition below draws: a client-decorated window
// gets only the border, so counting the title bar would size its client 30px
// past what the layout meant (and past the client's own maximum). The border
// is drawn for both, so it is counted for both; a config that drops the
// border for client-decorated windows must drop WINDOW_BORDER_PX here too.
function naturalRootRect(window: WaylandWindow): ManagedWindowRect {
  const client = window.position;
  // Client-decorated windows (VS Code, GTK apps) draw their own top edge and
  // get only the border; server-decorated ones get the title bar and the glass
  // frame down the sides and along the bottom.
  if (usesClientDecoration(window.decoration.peek())) {
    return {
      x: client.x - WINDOW_BORDER_PX,
      y: client.y - WINDOW_BORDER_PX,
      width: client.width + WINDOW_BORDER_PX * 2,
      height: client.height + WINDOW_BORDER_PX * 2,
    };
  }
  return {
    x: client.x - WINDOW_BORDER_PX - GLASS_FRAME_PX,
    y: client.y - TITLEBAR_HEIGHT - WINDOW_BORDER_PX,
    width: client.width + (WINDOW_BORDER_PX + GLASS_FRAME_PX) * 2,
    height: client.height + TITLEBAR_HEIGHT + GLASS_FRAME_PX + WINDOW_BORDER_PX * 2,
  };
}

/**
 * The title bar's button size, padding and gap. `titlebarButtonAt` finds the
 * buttons with the same numbers, so change them here.
 */
const TITLEBAR_BUTTON_SIZE = 13;
const TITLEBAR_PADDING_X = 12;
const TITLEBAR_GAP = 8;

COMPOSITOR.window.composition = (window: WaylandWindow) => {
  const useClientDecoration = usesClientDecoration(window.decoration());
  const workspaceVisible = window.state[WINDOW_STATE_WORKSPACE_VISIBLE];
  const workspaceOffsetY = window.state[WINDOW_STATE_WORKSPACE_OFFSET_Y];
  const workspaceOpacity = window.state[WINDOW_STATE_WORKSPACE_OPACITY];
  const tileDragging = window.state[WINDOW_STATE_TILE_DRAGGING];
  const managedRect = computed(() => {
    const rect = window.state[WINDOW_STATE_RECT]();
    return {
      x: read(rect.x),
      y: read(rect.y) + workspaceOffsetY(),
      width: read(rect.width),
      height: read(rect.height),
    };
  });
  const forceRectSize = computed(
    () => window.isResizable() && !window.isTransient(),
  );

  // force no corner rounding CSD
  const tiled = true;

  const zIndex = computed(() => windowZIndex(window));
  const minimizeVisualIdle = window.state[WINDOW_STATE_MINIMIZE_VISUAL_IDLE];
  const inactive = computed(
    () => minimizeVisualIdle() || (!workspaceVisible() && !tileDragging()),
  );

  // The edge of the glass, as on the bar and dock: a light rim.
  const borderColor = computed(() =>
    window.isFocused()
      ? themeDark() ? "#ffffff55" : "#ffffffb3"
      : themeDark() ? "#ffffff2b" : "#ffffff66",
  );
  // A soft drop shadow under the frame; the focused window floats a bit higher.
  // The window selected in the window switcher glows white instead (it fits
  // in the switcher's texture margin).
  const windowShadow = computed(() =>
    WINDOW_SWITCHER.selectedWindowId() === window.id
      ? [{ blur: 28, spread: 4, color: "#ffffffd0" }]
      : window.isFocused()
        ? [{ y: 12, blur: 36, spread: -4, color: themeDark() ? "#00000090" : "#3a3f6a40" }]
        : [{ y: 4, blur: 18, spread: -4, color: themeDark() ? "#00000060" : "#3a3f6a26" }],
  );
  // A light tint over the frame glass, as on macOS: enough that the title
  // stays readable over a dark window behind (VS Code) or a light one.
  const titlebarBackground = computed(() =>
    themeDark()
      ? window.isFocused() ? "#1c1c1e80" : "#2a2a2e66"
      : window.isFocused() ? "#f6f6f880" : "#ececf066",
  );
  const titleColor = computed(() =>
    themeDark()
      ? window.isFocused() ? "#f2f1f8" : "#b9bccb"
      : window.isFocused() ? "#262838" : "#6b6e80",
  );

  const titlebarStyle: SSDStyle = {
    height: TITLEBAR_HEIGHT,
    paddingX: TITLEBAR_PADDING_X,
    gap: TITLEBAR_GAP,
    alignItems: "center",
    background: titlebarBackground,
  };

  const backgroundShader = compileEffect({
    input: backdropSource(),
    capturePadding: 24,
    invalidate: { kind: "on-source-damage-box", damagePadding: 8 },
    pipeline: [
      // Hyalo: the same glass as the bar and dock (ISLAND_GLASS): the same light
      // blur, a lens at the rim, its colour fringe and specular line, no tint.
      dualKawaseBlur({ radius: 2, passes: 1 }),
      shaderStage(loadShader("./src/effect/liquid-glass.frag"), {
        uniforms: {
          // Follow the window's rounded corners.
          glass_radius_px: -1.0,
          distortion_depth: 0.12,
          distortion_strength: 0.03,
          chromatic_shift_px: 1.9,
          glass_tint: 1.0,
          highlight_strength: 0.6,
          highlight_width_px: 2.0,
        },
      }),
      backdropFade(),
    ],
    alpha: "preserve",
  });

  const titleOnlyShader = compileEffect({
    input: backdropSource(),
    capturePadding: 24,
    invalidate: { kind: "on-source-damage-box", damagePadding: 8 },
    alpha: "preserve",
    pipeline: [dualKawaseBlur({ radius: 4, passes: 2 }), backdropFade()],
  });
  // No backdrop effects while the window switcher shows the windows as
  // textures: there is nothing under a window there to blur.
  const blurSuspended = WINDOW_SWITCHER.blurSuspended();

  const label = (
    <Label
      text={window.title}
      style={{
        color: titleColor,
        fontFamily: ["SF Pro Text", "Noto Sans CJK JP", "Noto Color Emoji"],
        fontSize: 13,
        fontWeight: 600,
        flexGrow: 1,
        flexShrink: 1,
        minWidth: 0,
        textAlign: "center",
      }}
    />
  );
  const minimizeButton = <MinimizeButton window={window} />;
  const maximizeButton = <MaximizeButton window={window} />;
  const closeButton = <CloseButton window={window} />;

  // macOS order: the traffic lights on the left, the title centred on the
  // window (the spacer on the right balances the buttons).
  const titlebarContent = [
    closeButton,
    minimizeButton,
    maximizeButton,
    label,
    <Box style={{ width: TITLEBAR_BUTTON_SIZE * 3 + TITLEBAR_GAP * 2, flexShrink: 0 }} />,
  ];
  var innerComponents = (
    <Box direction="column">
      {blurSuspended ? (
        <Box direction="row" style={titlebarStyle}>
          {titlebarContent}
        </Box>
      ) : (
        <ShaderEffect
          shader={titleOnlyShader}
          direction="row"
          style={titlebarStyle}
        >
          {titlebarContent}
        </ShaderEffect>
      )}
      <ClientWindow />
    </Box>
  );

  // Every server-decorated window is framed in the glass (it shows through
  // the title bar, and behind translucent clients such as the terminal).
  {
    const terminalContent = [
      <Box direction="row" style={titlebarStyle}>
        {titlebarContent}
      </Box>,
      <Box
        style={{
          paddingLeft: GLASS_FRAME_PX,
          paddingRight: GLASS_FRAME_PX,
          paddingBottom: GLASS_FRAME_PX,
          background: titlebarBackground,
        }}
      >
        <Box style={{ borderRadius: CLIENT_RADIUS_PX, overflow: "hidden" }}>
          <ClientWindow />
        </Box>
      </Box>,
    ];
    innerComponents = blurSuspended ? (
      <Box direction="column">{terminalContent}</Box>
    ) : (
      <ShaderEffect shader={backgroundShader} direction="column">
        {terminalContent}
      </ShaderEffect>
    );
  }

  // Fullscreen: drop all chrome (titlebar, border, rounded corners) and let
  // the client surface fill its managed rect edge to edge. The rect is set to
  // the whole output by onWindowFullscreenRequest. Rendering nothing but the
  // bare ClientWindow is also what lets the tty backend promote the client
  // buffer to the primary plane (direct scanout).
  if (window.state[WINDOW_STATE_FULLSCREEN]()) {
    return (
      <ManagedWindow
        rect={managedRect}
        zIndex={FULLSCREEN_Z_INDEX}
        visibleOutputs={window.state[WINDOW_STATE_VISIBLE_OUTPUTS]}
        opacity={workspaceOpacity}
        forceRectSize={forceRectSize}
        tiled={tiled}
        idle={inactive}
        interactive={inactive((value) => !value)}
        // Permit low-latency tearing for fullscreen windows. The compositor only actually tears
        // once the window is on the direct-scanout fast path and is committing faster than the
        // refresh rate (i.e. games), so this is a no-op for ordinary fullscreen apps. Narrow it
        // per app if desired, e.g. `allowTearing={isGame(window.appId())}`.
        allowTearing={true}
      >
        <ClientWindow />
      </ManagedWindow>
    );
  }

  // use less Server-Side Decoration
  if (useClientDecoration) {
    return (
      <ManagedWindow
        rect={managedRect}
        zIndex={zIndex}
        visibleOutputs={window.state[WINDOW_STATE_VISIBLE_OUTPUTS]}
        opacity={workspaceOpacity}
        forceRectSize={forceRectSize}
        tiled={tiled}
        idle={inactive}
        interactive={inactive((value) => !value)}
      >
        <WindowBorder
          style={{
            border: { px: WINDOW_BORDER_PX, color: borderColor },
            borderRadius: 12,
            boxShadow: windowShadow,
            background: "#10131900",
            padding: 0,
            paddingX: 0,
            paddingRight: 0,
          }}
          interaction={{
            resizeHitArea: {
              edgePx: 8,
              cornerPx: 14,
            },
          }}
        >
          <ClientWindow />
        </WindowBorder>
      </ManagedWindow>
    );
  }

  // use full Server-Side Decoration
  return (
    <ManagedWindow
      rect={managedRect}
      zIndex={zIndex}
      visibleOutputs={window.state[WINDOW_STATE_VISIBLE_OUTPUTS]}
      opacity={workspaceOpacity}
      forceRectSize={forceRectSize}
      tiled={tiled}
      idle={inactive}
      interactive={inactive((value) => !value)}
    >
      <WindowBorder
        style={{
          border: { px: WINDOW_BORDER_PX, color: borderColor },
          borderRadius: 12,
          boxShadow: windowShadow,
          background: "#10131900",
          padding: 0,
          paddingX: 0,
          paddingRight: 0,
        }}
        interaction={{
          resizeHitArea: {
            edgePx: 8,
            cornerPx: 14,
          },
        }}
      >
        <Box direction="row">{innerComponents}</Box>
      </WindowBorder>
    </ManagedWindow>
  );
};

/**
 * The title bar button at `(x, y)`, logical px from the top-left corner of
 * `window.rect` (the frame: border, then the title bar). From the left, as on
 * macOS: close, minimize, maximize. Each button takes the whole title bar height
 * and half the gap on both sides, so a scaled-down card still has a usable
 * target.
 */
function titlebarButtonAt(window: WaylandWindow, x: number, y: number): TitlebarButton | null {
  if (
    window.state[WINDOW_STATE_FULLSCREEN].peek() ||
    usesClientDecoration(window.decoration.peek())
  ) {
    return null;
  }
  if (y < WINDOW_BORDER_PX || y > WINDOW_BORDER_PX + TITLEBAR_HEIGHT) {
    return null;
  }
  const buttons: TitlebarButton[] = ["close", "minimize", "maximize"];
  const pitch = TITLEBAR_BUTTON_SIZE + TITLEBAR_GAP;
  const left = WINDOW_BORDER_PX + TITLEBAR_PADDING_X;
  for (let i = 0; i < buttons.length; i++) {
    const center = left + TITLEBAR_BUTTON_SIZE / 2 + i * pitch;
    if (Math.abs(x - center) <= pitch / 2) {
      return buttons[i];
    }
  }
  return null;
}

const CloseButton = ({ window }: { window: WaylandWindow }) => {
  const [hover, setHover] = useState(false);

  // macOS traffic lights: coloured on the focused window, grey otherwise.
  const buttonBackground = window.isFocused((focused) => (focused ? "#ff5f57" : "#c8c7cc"));
  const borderColor = window.isFocused((focused) => (focused ? "#e2463f" : "#b6b5ba"));

  var icon: CompositionRenderable | null = null;
  if (hover()) {
    icon = (
      <Image
        src="./assets/x.svg"
        style={{
          width: TITLEBAR_BUTTON_SIZE,
          height: TITLEBAR_BUTTON_SIZE,
          position: "absolute",
          zIndex: 1,
          pointerEvents: "none",
        }}
      />
    );
  }

  return (
    <Box style={{ position: "relative", flexShrink: 0 }}>
      <Button
        onHoverChange={setHover}
        style={{
          width: TITLEBAR_BUTTON_SIZE,
          height: TITLEBAR_BUTTON_SIZE,
          borderRadius: TITLEBAR_BUTTON_SIZE / 2,
          background: buttonBackground,
          border: { px: 1, color: borderColor },
        }}
        onClick={window.close}
      />
      {icon}
    </Box>
  );
};

/** How long the pointer has to rest on a title bar button before its tooltip shows. */
const TOOLTIP_DELAY_MS = 500;

/**
 * A small label under a title bar button, drawn above every window. It
 * opens once the pointer has rested on the button for `TOOLTIP_DELAY_MS` and
 * closes as soon as it leaves.
 */
const TitlebarTooltip = ({
  text,
}: {
  text: string | ReadonlySignal<string>;
}) => (
  <Popup
    trigger="hover"
    openDelay={TOOLTIP_DELAY_MS}
    closeDelay={0}
    placement="bottom"
    offset={8}
  >
    <Box
      style={{
        background: "#1f2430e6",
        borderRadius: 6,
        paddingX: 8,
        paddingY: 4,
        border: { px: 1, color: "#ffffff1f" },
        boxShadow: [{ y: 4, blur: 12, color: "#00000070" }],
      }}
    >
      <Label
        text={text}
        style={{
          color: "#e6e9ef",
          fontFamily: ["SF Pro Text", "Noto Sans CJK JP", "Noto Color Emoji"],
          fontSize: 12,
        }}
      />
    </Box>
  </Popup>
);

const MaximizeButton = ({ window }: { window: WaylandWindow }) => {
  const [hover, setHover] = useState(false);

  const buttonBackground = computed(() =>
    window.isFocused() && window.isResizable() ? "#28c840" : "#c8c7cc",
  );
  const borderColor = computed(() =>
    window.isFocused() && window.isResizable() ? "#1aab29" : "#b6b5ba",
  );
  const shouldHover = computed(() => hover() && window.isResizable());

  var icon: CompositionRenderable | null = null;
  if (shouldHover()) {
    const src = window.isMaximized((maximized) => {
      return maximized ? "./assets/minimize-2.svg" : "./assets/maximize-2.svg";
    });

    icon = (
      <Image
        src={src}
        style={{
          width: TITLEBAR_BUTTON_SIZE,
          height: TITLEBAR_BUTTON_SIZE,
          position: "absolute",
          zIndex: 1,
          pointerEvents: "none",
        }}
      />
    );
  }

  return (
    <Box style={{ position: "relative", flexShrink: 0 }}>
      <Button
        onHoverChange={setHover}
        style={{
          width: TITLEBAR_BUTTON_SIZE,
          height: TITLEBAR_BUTTON_SIZE,
          borderRadius: TITLEBAR_BUTTON_SIZE / 2,
          background: buttonBackground,
          border: { px: 1, color: borderColor },
        }}
        onClick={() => {
          if (!read(window.isResizable)) {
            return;
          }

          if (read(window.isMaximized)) {
            window.unmaximize();
          } else {
            window.maximize();
          }
        }}
      />
      {icon}
      {window.isResizable() ? (
        <TitlebarTooltip
          text={window.isMaximized((maximized) =>
            maximized ? "Restore" : "Maximize",
          )}
        />
      ) : null}
    </Box>
  );
};

const MinimizeButton = ({ window }: { window: WaylandWindow }) => {
  const [hover, setHover] = useState(false);

  const buttonBackground = window.isFocused((focused) => (focused ? "#febc2e" : "#c8c7cc"));
  const borderColor = window.isFocused((focused) => (focused ? "#e1a116" : "#b6b5ba"));

  var icon: CompositionRenderable | null = null;
  if (hover()) {
    icon = (
      <Image
        src="./assets/minus.svg"
        style={{
          width: TITLEBAR_BUTTON_SIZE,
          height: TITLEBAR_BUTTON_SIZE,
          position: "absolute",
          zIndex: 1,
          pointerEvents: "none",
        }}
      />
    );
  }

  return (
    <Box style={{ position: "relative", flexShrink: 0 }}>
      <Button
        onHoverChange={setHover}
        style={{
          width: TITLEBAR_BUTTON_SIZE,
          height: TITLEBAR_BUTTON_SIZE,
          borderRadius: TITLEBAR_BUTTON_SIZE / 2,
          background: buttonBackground,
          border: { px: 1, color: borderColor },
        }}
        onClick={() => window.minimize()}
      />
      {icon}
      <TitlebarTooltip text="Minimize" />
    </Box>
  );
};

export default COMPOSITOR;
