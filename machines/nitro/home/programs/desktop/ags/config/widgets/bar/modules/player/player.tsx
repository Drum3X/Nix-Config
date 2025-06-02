// Astal
import { bind, Binding, Variable } from "astal";
import { Gtk } from "astal/gtk4";

// Libraries
import Mpris from "gi://AstalMpris"

interface Props {
    revealChild: Variable<boolean>,
    player: Mpris.Player | undefined
}

const PlayerComponent = ({ revealChild, player }: Props) => {
    const playIcon = player
        ? bind(player, "playbackStatus").as(
            status => status === Mpris.PlaybackStatus.PLAYING ? "" : ""
        )
        : "";

    const getButtonClasses = (property: keyof Mpris.Player) => player
        ? bind(player, property).as(
            can => ([
                "PlayerButton",
                !can ? "PlayerButtonInactive" : null
            ].filter((x): x is string => Boolean(x)))
        )
        : ["PlayerButton", "PlayerButtonInactive"];

    return (
        <revealer
            revealChild={revealChild(val => val)}
            transitionType={Gtk.RevealerTransitionType.CROSSFADE}
        >
            <box cssClasses={["Player"]} valign={Gtk.Align.CENTER}>
                <button
                    cssClasses={getButtonClasses("can_go_previous")}
                    onClicked={() => {
                        player?.can_go_previous && player.previous();
                    }}
                >
                    󰒮
                </button>

                <button
                    cssClasses={getButtonClasses("can_play")}
                    onClicked={() => {
                        player?.can_play && player.play_pause();
                    }}
                >
                    <label label={playIcon} />
                </button>

                <button
                    cssClasses={getButtonClasses("can_go_next")}
                    onClicked={() => {
                        player?.can_go_next && player.next()
                    }}
                >
                    󰒭
                </button>
            </box>
        </revealer>
    )
}

export default PlayerComponent;