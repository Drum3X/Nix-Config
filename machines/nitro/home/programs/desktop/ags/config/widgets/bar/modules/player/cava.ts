// Astal
import { Gtk, Gdk, astalify } from "astal/gtk4";
import { property, register } from "astal";

// Libraries
import Adw from "gi://Adw";
import Gsk from "gi://Gsk";
import Graphene from "gi://Graphene";

@register({
    CssName: "BackgroundBin",
})
export class BackgroundBin extends Adw.Bin {
    constructor(props?: Partial<Gtk.Widget.ConstructorProps>) {
        super(props);

        this.set_layout_manager(new Gtk.BinLayout());
    }

    draw(snapshot: Gtk.Snapshot, fullRect: Graphene.Rect) {
        const color = new Gdk.RGBA({ red: 1, green: 1, blue: 1, alpha: 1 });
        const roundedRect = new Gsk.RoundedRect().init_from_rect(fullRect, fullRect.get_height() / 2);

        snapshot.push_rounded_clip(roundedRect);
        snapshot.append_node(Gsk.ColorNode.new(color, fullRect));
        snapshot.pop();
    }

    vfunc_snapshot(snapshot: Gtk.Snapshot): void {
        const width = this.get_width();
        const height = this.get_height();

        const fullRect = new Graphene.Rect({
            origin: new Graphene.Point({ x: 0, y: 0 }),
            size: new Graphene.Size({ width, height }),
        });
        this.draw(snapshot, fullRect);

        for (let child = this.get_first_child(); child != null; child = child.get_next_sibling()) {
            this.snapshot_child(child, snapshot);
        }
    }
}

interface GraphBinConstructorProps extends Adw.Bin.ConstructorProps {
    values: number[];
}

@register({
    CssName: "GraphBin",
})
export class GraphBin extends BackgroundBin {
    #values!: number[];
    color!: Gdk.RGBA;

    @property(Object)
    set values(data: number[]) {
        this.#values = data;
        this.queue_draw();
    }

    get values() {
        return this.#values;
    }

    constructor(props?: Partial<GraphBinConstructorProps>) {
        super(props);
        if (!this.values) {
            this.values = [];
        }

        this.cssClasses = ["GraphBin"]
        this.color = this.get_style_context().get_color();
    }

    draw(snapshot: Gtk.Snapshot, fullRect: Graphene.Rect) {
        const width = fullRect.get_width();
        const height = fullRect.get_height();
        const roundedRect = new Gsk.RoundedRect().init_from_rect(fullRect, height / 2);

        snapshot.push_rounded_clip(roundedRect);

        if (this.values.length > 1) {
            const builder = new Gsk.PathBuilder();
            builder.move_to(0, height);

            let prevX = 0;
            let prevY = height * (1 - Math.pow(Math.max(Math.min(1, this.#values[0]), 0), 0.75));

            for (let i = 1; i < this.#values.length; i++) {
                const x = width * (i / (this.#values.length - 1));
                const y = height * (1 - Math.pow(Math.max(Math.min(1, this.#values[i]), 0), 0.75));

                const controlX1 = (prevX + x) / 2;
                const controlY1 = prevY;
                const controlX2 = (prevX + x) / 2;
                const controlY2 = y;

                builder.cubic_to(controlX1, controlY1, controlX2, controlY2, x, y);

                prevX = x;
                prevY = y;
            }

            builder.line_to(width, height);
            builder.close();
            const path = builder.to_path();
            snapshot.append_fill(path, Gsk.FillRule.EVEN_ODD, this.color);
        }
        snapshot.pop();
    }
}

const Cava = astalify<GraphBin, GraphBinConstructorProps>(GraphBin, {
    getChildren(widget) {
        return [widget.child];
    },
    setChildren(widget, children) {
        widget.child = children[0];
    },
});

export default Cava;