// Astal
import { bind, Variable } from "astal";

// Libraries
import AstalCava from "gi://AstalCava";
import Mpris from "gi://AstalMpris"

// Components
import WidgetBox from "../../components/box";
import Cava from "./cava";
import PlayerComponent from "./player";

const Player = () => {
    const mpris = Mpris.get_default();

    const revealChild = Variable<boolean>(false);
    const isHover = Variable<boolean>(false);

    const cava = AstalCava.get_default()!;

    bind(cava, "values").subscribe((values: number[]) => {
        if (isHover.get()) {
            revealChild.set(true);
        } else {
            revealChild.set(values.every(num => num < 0.05));
        }
    })

    cava.bars = 8;
    cava.autosens = true;
    cava.framerate = 60;
    cava.channels = 1;

    return (
        <WidgetBox
            cssClasses={["Cava", "WidgetBox"]}

            onHoverEnter={() => {
                isHover.set(true)
            }}

            onHoverLeave={() => {
                isHover.set(false);
            }}
        >
            <Cava values={bind(cava, "values")}>
                {bind(mpris, "players").as((players) => {
                    return (
                        <PlayerComponent
                            revealChild={revealChild}
                            player={Mpris.Player.new("spotify").can_control
                                ? Mpris.Player.new("spotify")
                                : players.length > 0 ? players[0] : undefined
                            }
                        />
                    )
                })}
            </Cava>
        </WidgetBox>
    )
}

export default Player;