// Astal
import { bind } from "astal";

// Libraries
import Hyprland from "gi://AstalHyprland";

// Components
import WidgetBox from "../../components/box";
import WorkspaceButton from "./button";

const Workspaces = () => {
    const hyprland = Hyprland.get_default();

    const scrollEvent = ({ }, { }, dy: number) => {
        if (hyprland.workspaces.length > 1 && dy < 0) {
            hyprland.dispatch("workspace", "m+1");
        } else if (hyprland.workspaces.length > 1 && dy > 0) {
            hyprland.dispatch("workspace", "m-1");
        }
    }

    const workspaceFilter = (workspace: Hyprland.Workspace) => !(workspace.id >= -99 && workspace.id <= -2);
    const workspaceSorter = (a: Hyprland.Workspace, b: Hyprland.Workspace) => a.id - b.id;

    return (
        <WidgetBox
            cssClasses={["WidgetBox", "Workspaces"]}
            onScroll={scrollEvent}
        >
            {bind(hyprland, "workspaces").as(workspaces => workspaces
                .filter(workspaceFilter)
                .sort(workspaceSorter)
                .map((workspace) => WorkspaceButton(hyprland, workspace))
            )}
        </WidgetBox>
    )
}

export default Workspaces;