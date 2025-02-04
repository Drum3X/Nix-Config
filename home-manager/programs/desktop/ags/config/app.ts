import { App } from "astal/gtk3"
import style from "./style/main.scss"

import Bar from "./widget/Bar"
import OSDWindow from "./widget/OSD"
import NotificationPopups from "./widget/Notification"

App.start({
    css: style,
    instanceName: "astal",
    requestHandler(request, res) {
        print(request)
        res("ok")
    },
    main: () => {
        const mainMonitor = App.get_monitors()[0]

        App.get_monitors().map(Bar)
        App.get_monitors().map(NotificationPopups)
        OSDWindow(mainMonitor)
    },
})