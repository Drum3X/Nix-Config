// Astal
import { App } from "astal/gtk4";
import { exec } from "astal";

const requestHandler = (request: string, res: (response: any) => void) => {
    if (request === "reload") {
        App.reset_css();
        exec([
            "sass",
            "./style/main.scss",
            "/tmp/style.css"
        ]);
        App.apply_css("/tmp/style.css");

        return res("styles reloaded");
    }

    res("unknown command");
}

export default requestHandler;