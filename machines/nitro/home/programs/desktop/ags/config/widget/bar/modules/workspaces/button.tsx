// Astal
import { bind } from "astal";

// Libraries
import Hyprland from "gi://AstalHyprland";

const WorkspaceButton = (hyprland: Hyprland.Hyprland, workspace: Hyprland.Workspace) => {
    bind(hyprland, "focusedWorkspace")
        .as(focusedWorkspace => workspace === focusedWorkspace ? "focused" : "")
    return (
        <button
            cssClasses={bind(hyprland, "focusedWorkspace").as(focusedWorkspace => workspace === focusedWorkspace
                ? ["focused"]
                : [""]
            )}
            onClicked={() => {
                if (hyprland.focusedWorkspace !== workspace) {
                    workspace.focus();
                }
            }}>
        </button >
    )
}

export default WorkspaceButton;