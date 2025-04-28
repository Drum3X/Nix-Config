// Astal
import { App } from "astal/gtk4";
import { exec } from "astal";

// Styles
import style from "./style/main.scss";

// Modules
import { Bar, Corners } from "./widget";

App.start({
    css: style,
    requestHandler(request: string, res: (response: any) => void) {
        if (request === "reload") {
            App.reset_css();
            exec([
                "sass",
                "./style/main.scss",
                "/tmp/style.css"
            ]);
            App.apply_css("/tmp/style.css");

            return res("styles reloaded")
        }
        res("unknown command")
    },
    main() {
        Bar()

        App.get_monitors().map(Corners);
    },
})
