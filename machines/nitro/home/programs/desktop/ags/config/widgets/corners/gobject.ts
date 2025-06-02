// Astal
import { Gdk, Gtk } from "astal/gtk4";

// Libraries            
import GObject from "gi://GObject";
import Gsk from "gi://Gsk";

const CornerObject = GObject.registerClass(
    class Corner extends Gtk.Widget {
        gdkmonitor!: Gdk.Monitor;
        radius!: number;

        constructor(gdkmonitor: Gdk.Monitor, radius: number) {
            super();
            this.gdkmonitor = gdkmonitor;
            this.radius = radius;
            this.set_size_request(radius, radius);
        }

        vfunc_snapshot(snapshot: Gtk.Snapshot) {
            const width = this.gdkmonitor.get_geometry().width;
            const height = this.gdkmonitor.get_geometry().height;
            const color = new Gdk.RGBA();
            color.parse("#000000");

            const pathbuilder = new Gsk.PathBuilder;


            pathbuilder.move_to(0, 0);
            pathbuilder.line_to(0, this.radius);
            pathbuilder.conic_to(0, 0, this.radius, 0, 1);

            pathbuilder.move_to(width, 0);
            pathbuilder.line_to(width, this.radius);
            pathbuilder.conic_to(width, 0, width - this.radius, 0, 1);

            pathbuilder.move_to(width, height);
            pathbuilder.line_to(width, height - this.radius);
            pathbuilder.conic_to(width, height, width - this.radius, height, 1);

            pathbuilder.move_to(0, height);
            pathbuilder.line_to(0, height - this.radius);
            pathbuilder.conic_to(0, height, this.radius, height, 1);

            snapshot.append_fill(pathbuilder.to_path(), Gsk.FillRule.EVEN_ODD, color);
        }
    }
);

export default CornerObject;