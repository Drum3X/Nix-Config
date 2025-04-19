// Astal
import { App, } from "astal/gtk4"

// Styles
import style from "./style/main.scss";

// Modules
import { Bar, Corners } from "./widget";

App.start({
    css: style,
    main() {
        Bar()

        App.get_monitors().map(Corners);
    },
})
