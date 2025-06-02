// Astal
import { bind } from "astal";

// Libraries
import Tray from "gi://AstalTray"

const itemMap = (item: Tray.TrayItem) => {
    const menuModel = bind(item, "menuModel");

    return (
        <menubutton
            cssClasses={["SystemTray"]}
            menuModel={menuModel}
            sensitive={menuModel.as((model) => model && model.get_n_items() > 1)}
            setup={(self) => {
                self.insert_action_group("dbusmenu", item.actionGroup);
            }}
        >
            <image gicon={bind(item, "gicon")} />
        </menubutton>
    )
}

export default itemMap;