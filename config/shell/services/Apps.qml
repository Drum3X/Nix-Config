pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Desktop entries for the launcher, ranked by match quality and by how often
// each one has been launched from it.
Singleton {
    id: root

    readonly property var entries: {
        const all = DesktopEntries.applications ? DesktopEntries.applications.values : [];
        return all.filter((entry) => !entry.noDisplay);
    }

    // { "<entry id>": launches }
    property var usage: ({})

    function score(entry, query: string): real {
        const name = (entry.name || "").toLowerCase();
        if (query === "")
            return 1 + (usage[entry.id] || 0);
        let base = 0;
        if (name === query)
            base = 100;
        else if (name.startsWith(query))
            base = 60;
        else if (name.split(/[\s\-_.]/).some((word) => word.startsWith(query)))
            base = 40;
        else if (name.includes(query))
            base = 25;
        else if ((entry.genericName || "").toLowerCase().includes(query)
                 || (entry.keywords || []).some((k) => k.toLowerCase().includes(query))
                 || (entry.id || "").toLowerCase().includes(query))
            base = 10;
        else
            return 0;
        return base + Math.min(20, (usage[entry.id] || 0) * 2);
    }

    function search(text: string): var {
        const query = text.trim().toLowerCase();
        return entries
            .map((entry) => ({ entry: entry, score: score(entry, query) }))
            .filter((item) => item.score > 0)
            .sort((a, b) => b.score - a.score || a.entry.name.localeCompare(b.entry.name))
            .slice(0, 40)
            .map((item) => item.entry);
    }

    function launch(entry): void {
        const next = Object.assign({}, usage);
        next[entry.id] = (next[entry.id] || 0) + 1;
        usage = next;
        store.setText(JSON.stringify(usage));
        entry.execute();
    }

    FileView {
        id: store
        path: `${Quickshell.statePath("launcher-usage.json")}`
        blockLoading: true
        printErrors: false
        onLoaded: {
            try {
                root.usage = JSON.parse(text()) || {};
            } catch (e) {
                root.usage = {};
            }
        }
    }
}
