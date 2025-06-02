// Astal
import { Gtk } from "astal/gtk4";
import { bind, timeout } from "astal";

// Libraries 
import AstalBattery from "gi://AstalBattery"

// Components
import WidgetBox from "../../components/box"

const Battery = () => {
    const battery = AstalBattery.get_default();
    const percentage = bind(battery, "percentage");

    const isVisible = percentage.as((percentage) => {
        return !(percentage === 1.0 && battery.charging)
    })

    const setVisibility = (self: Gtk.Revealer) => {
        self.set_visible(!(battery.percentage === 1.0 && battery.charging));
    }

    return (
        <revealer
            revealChild={isVisible}
            transitionType={Gtk.RevealerTransitionType.CROSSFADE}
            setup={(self) => {
                setVisibility(self);

                self.connect("notify::child-revealed", () => {
                    setVisibility(self);
                })
            }}
        >
            <WidgetBox cssClasses={["Battery", "WidgetBox"]}>
                <levelbar
                    widthRequest={80}
                    mode={Gtk.LevelBarMode.CONTINUOUS}
                    overflow={Gtk.Overflow.HIDDEN}
                    maxValue={1}
                    value={percentage}
                >
                    <label
                        cssClasses={percentage.as((percentage) => percentage <= 0.25
                            ? ["LabelLow"]
                            : []
                        )}
                        label={percentage.as((percentage: number) => `${Math.floor(percentage * 100)}%`)}
                    />
                </levelbar>
            </WidgetBox>
        </revealer >
    )
}

export default Battery;