import { Astal, Gtk, Gdk } from "astal/gtk3"

import Workspaces from "./modules/Workspaces"
import SysTray from "./modules/SysTray"
import Time from "./modules/Time"
import Wifi from "./modules/Wifi"
import AudioSlider from "./modules/AudioSlider"
import BatteryLevel from "./modules/BatteryLevel"


export default function Bar(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Bar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}
        margin={10}
        marginBottom={0}
    >
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <Workspaces />
                <SysTray />
            </box>
            <box>
                <Time />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <Wifi />
                <AudioSlider />
                <BatteryLevel />
            </box>
        </centerbox>
    </window>
}