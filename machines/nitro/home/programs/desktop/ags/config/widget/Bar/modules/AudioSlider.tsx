import { Widget, Gtk } from "astal/gtk3";
import { bind, Binding, Variable } from "astal";
import Wp from "gi://AstalWp";

const audio = Wp.get_default()?.get_audio();

function VolumeIcon() {

    const volumeThresholds = [101, 67, 34, 1, 0];

    const setupStack = (stack: Widget.Stack) => {
        if (!audio)
            return

        audio.get_default_speaker()?.connect("notify", ((speaker) => {
            if (speaker.get_mute()) {
                stack.shown = "0";
                return;
            }

            const detectedThresholds = volumeThresholds.find(threshold => threshold <= (speaker.volume * 100))

            stack.shown = String(detectedThresholds ?? 0);
        }))
    }

    return (
        <box className="AudioIcon">
            <button onClick={() => {
                const speaker = audio?.get_default_speaker();
                if (!speaker) return;

                const current = speaker.get_mute();
                speaker.set_mute(!current);
            }}>
                <stack setup={(setupStack)}>
                    <icon name="101" icon="audio-volume-overamplified-symbolic" />
                    <icon name="67" icon="audio-volume-high-symbolic" />
                    <icon name="34" icon="audio-volume-medium-symbolic" />
                    <icon name="1" icon="audio-volume-low-symbolic" />
                    <icon name="0" icon="audio-volume-muted-symbolic" />
                </stack>
            </button>
        </box>
    )
}

interface RevealerProps {
    revealChild: boolean | Binding<boolean>
}

function PercentBar({ revealChild }: RevealerProps) {
    return (
        <revealer
            transitionType={Gtk.RevealerTransitionType.SLIDE_RIGHT}
            revealChild={revealChild}
        >
            <slider className="AudioSlider"
                hexpand={true}
                drawValue={false}
                value={bind(audio!.get_default_speaker()!, "volume")}
                onDragged={(slider) => {
                    const value = slider.get_value();
                    audio?.defaultSpeaker?.set_volume(value);
                }}
            >
            </slider>
        </revealer>
    )
}

export default function AudioSlider() {
    const revealChild = Variable(false);

    return (
        <eventbox
            className="volume"
            onHover={() => revealChild.set(true)}
            onHoverLost={(widget, event) => {
                revealChild.set(false);
            }}
        >
            <box>
                <VolumeIcon />
                <PercentBar revealChild={bind(revealChild)} />
            </box>
        </eventbox>

    )
}