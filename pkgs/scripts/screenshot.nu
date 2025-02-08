#!/usr/bin/env nu

let SCREENSHOTS = $"($env.HOME)/Pictures/Screenshots"
let TARGET = $"($SCREENSHOTS)/(date now | format date %Y-%m-%d_%H-%M-%S).png"
let FM = "nemo"

def main [
    --full (-f) # Fullscreen
] {
    mkdir $SCREENSHOTS

    if $full {
        wayshot -f $TARGET
    } else {
        wayshot -f $TARGET -s (slurp)
    }

    open $TARGET | wl-copy

    let res = (notify-send
        -a "Screenshot"
        -i "image-x-generic-symbolic"
        -h $"string:image-path:($TARGET)"
        -A "file=Show in Files"
        -A "view=View"
        -A "edit=Edit"
        "Screenshot Taken"
        $TARGET
    )

    match $res {
        "file" => (exec $FM $SCREENSHOTS),
        "view" => (xdg-open $TARGET),
        "edit" => (swappy -f $TARGET),
        _ => exit,
    }
}