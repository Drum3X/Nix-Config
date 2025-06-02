// Astal
import { App } from "astal/gtk4";

// Styles
import style from "./styles/main.scss";

// Modules
import requestHandler from "./modules/handler";

// Widgets
import { Bar, Corners } from "./widgets";

App.start({
    css: style,
    requestHandler,
    main() {
        Bar()

        App.get_monitors().map(Corners);
    },
})
