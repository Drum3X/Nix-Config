pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// What the dock shows: pinned apps (from ~/.config/hyalo/dock.json, written by
// Home Manager) first, then whatever else has windows open, grouped by app.
Singleton {
    id: root

    readonly property var windows: ToplevelManager.toplevels ? ToplevelManager.toplevels.values : []
    readonly property var activeWindow: ToplevelManager.activeToplevel

    property var pinned: []

    function lookup(appId: string): var {
        if (!appId)
            return null;
        return DesktopEntries.byId(appId) || DesktopEntries.heuristicLookup(appId);
    }

    function keyFor(appId: string): string {
        const entry = lookup(appId);
        return entry ? entry.id : (appId || "").toLowerCase();
    }

    // [{ key, entry, name, icon, pinned, windows: [Toplevel] }]
    readonly property var items: {
        const list = [];
        const index = {};
        const add = (key, entry, isPinned) => {
            const item = {
                key: key,
                entry: entry,
                name: entry ? entry.name : key,
                icon: Quickshell.iconPath(entry && entry.icon ? entry.icon : key, "application-x-executable"),
                pinned: isPinned,
                windows: []
            };
            index[key] = item;
            list.push(item);
            return item;
        };
        for (let i = 0; i < pinned.length; i++) {
            const entry = lookup(pinned[i]);
            const key = entry ? entry.id : pinned[i];
            if (!index[key])
                add(key, entry, true);
        }
        for (let i = 0; i < windows.length; i++) {
            const window = windows[i];
            const key = keyFor(window.appId);
            const item = index[key] || add(key, lookup(window.appId), false);
            item.windows.push(window);
        }
        return list;
    }

    readonly property int pinnedCount: items.filter((item) => item.pinned).length

    // Click: launch when nothing is open; focus when something is; cycle
    // through the app's windows when it already has focus.
    function activate(item): void {
        if (item.windows.length === 0) {
            if (item.entry)
                item.entry.execute();
            return;
        }
        const focused = item.windows.indexOf(activeWindow);
        item.windows[(focused + 1) % item.windows.length].activate();
    }

    function launchNew(item): void {
        if (item.entry)
            item.entry.execute();
    }

    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || (Quickshell.env("HOME") + "/.config")) + "/hyalo/dock.json"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: {
            try {
                root.pinned = JSON.parse(text()).pinned || [];
            } catch (e) {
                root.pinned = [];
            }
        }
    }
}
