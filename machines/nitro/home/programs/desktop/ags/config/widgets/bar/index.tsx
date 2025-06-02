// Astal
import { Astal, App, Gtk } from "astal/gtk4"

// Modules
import {
    Workspaces,
    SystemTray,
    Time,
    Player,
    Battery
} from "./modules";

const Bar = () => {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

    return <window
        visible
        layer={Astal.Layer.TOP}
        application={App}
        name={"Bar"}
        namespace={"Bar"}
        cssClasses={["Bar"]}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | RIGHT | LEFT}
        keymode={Astal.Keymode.ON_DEMAND}
        margin={8}
        marginBottom={0}
    >
        <centerbox>
            <box cssClasses={["BarBox"]} hexpand halign={Gtk.Align.START} spacing={8}>
                <Workspaces />
                <SystemTray />
            </box>
            <box cssClasses={["BarBox"]} hexpand halign={Gtk.Align.CENTER} spacing={8}>
                <Player />
            </box>
            <box cssClasses={["BarBox"]} hexpand halign={Gtk.Align.END} spacing={8}>
                <Battery />
                <Time />
            </box>
        </centerbox>
    </window>
}

export default Bar;