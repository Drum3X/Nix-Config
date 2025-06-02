// Astal
import { Gtk } from "astal/gtk4";
import { Variable, GLib } from "astal"

// Components
import WidgetBox from "../../components/box";
import Menu from "../../components/menu";

const Time = () => {
    const updateTime = () => GLib.DateTime.new_now_local().format("%H:%M %d %b %a")!
    const time = Variable<string>("").poll(1000, updateTime);

    return (
        <WidgetBox cssClasses={["WidgetBox", "Time"]}>
            <menubutton >
                <label
                    cssClasses={["TimeLabel"]}
                    onDestroy={() => time.drop()}
                    label={time()}
                />
                <popover>
                    <Menu>
                        <Gtk.Calendar />
                    </Menu>
                </popover>
            </menubutton>
        </WidgetBox >
    )
}

export default Time;