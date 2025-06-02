// Astal
import { bind, Variable } from "astal";

// Libraries
import Tray from "gi://AstalTray"

// Components
import WidgetBox from "../../components/box"
import itemComponent from "./item"


const SystemTray = () => {
    const tray = Tray.get_default()

    const isVisible = Variable(true);

    return (
        <WidgetBox visible={bind(isVisible)}>
            <box spacing={8}>
                {bind(tray, "items").as((items) => {
                    isVisible.set(!(items.length === 0));

                    return items.map(itemComponent);
                })}
            </box>
        </WidgetBox>
    )
}

export default SystemTray;