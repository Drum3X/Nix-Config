import { timeout, Variable } from "astal";
import { App, Widget } from "astal/gtk3";

export const uptime = Variable("").poll(60_000, "cat /proc/uptime", (out) => {
    const uptime = Number.parseInt(out.split('.')[0]) / 60;
    if (uptime > 18 * 60)
        return 'Go Sleep';

    const h = Math.floor(uptime / 60);
    const s = Math.floor(uptime % 60);
    return `${h}:${s < 10 ? '0' + s : s}`;
});

export function toggleWindow(windowName: string, delay: number = 300) {
    const window = App.get_window(windowName);
    if (window === null)
        return
    if (window.is_visible()) {
        (window.get_child() as Widget.Revealer).revealChild = false;
        timeout(delay, () => window.hide());
    }
    else {
        window.show();
        (window.get_child() as Widget.Revealer).revealChild = true;
    }
}

export function hideWindow(windowName: string, delay: number = 300) {
    const window = App.get_window(windowName);
    if (window === null)
        return
    if (window.is_visible()) {
        (window.get_child() as Widget.Revealer).revealChild = false;
        timeout(delay, () => window.hide());
    }
}