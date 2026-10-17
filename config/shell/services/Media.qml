pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The player worth showing: the one playing, else the first one there is.
Singleton {
    id: root

    readonly property var players: Mpris.players ? Mpris.players.values : []
    readonly property var player: {
        for (let i = 0; i < players.length; i++) {
            if (players[i].isPlaying)
                return players[i];
        }
        return players.length > 0 ? players[0] : null;
    }

    readonly property bool active: player !== null
    readonly property bool playing: player ? player.isPlaying : false
    readonly property string title: player ? (player.trackTitle || player.identity || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string art: player ? (player.trackArtUrl || "") : ""

    function toggle(): void {
        if (player && player.canTogglePlaying)
            player.togglePlaying();
    }
    function next(): void {
        if (player && player.canGoNext)
            player.next();
    }
    function previous(): void {
        if (player && player.canGoPrevious)
            player.previous();
    }
}
