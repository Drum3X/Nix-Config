// Astal
import { Astal, App, Gdk } from "astal/gtk4";

// Objects
import CornerObject from "./gobject";

const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor;

const Corners = (gdkmonitor: Gdk.Monitor) => {
    const corners = new CornerObject(gdkmonitor, 24);

    return (
        <window
            visible
            layer={Astal.Layer.BACKGROUND}
            application={App}
            name={"Corner"}
            namespace={"Corners"}
            cssClasses={["Corners"]}
            exclusivity={Astal.Exclusivity.IGNORE}
            anchor={TOP | BOTTOM | RIGHT | LEFT}
            keymode={Astal.Keymode.NONE}
        >
            <box>
                {corners}
            </box>
        </window>
    )
}

export default Corners;