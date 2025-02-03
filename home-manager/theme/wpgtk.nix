{ pkgs, lib, ... }:
{
  home.packages = with pkgs; [
    wpgtk
  ];

  xdg.configFile."wal/templates/colors-hyprland.conf".text =
    "
    $foreground = rgb({foreground.strip})
    $color0 = rgb({color0.strip})
    $color1 = rgb({color1.strip})
    $color2 = rgb({color2.strip})
    $color3 = rgb({color3.strip})
    $color4 = rgb({color4.strip})
    $color5 = rgb({color5.strip})
    $color6 = rgb({color6.strip})
    $color7 = rgb({color7.strip})
    $color8 = rgb({color8.strip})
    $color9 = rgb({color9.strip})
    $color10 = rgb({color10.strip})
    $color11 = rgb({color11.strip})
    $color12 = rgb({color12.strip})
    $color13 = rgb({color13.strip})
    $color14 = rgb({color14.strip})
    $color15 = rgb({color15.strip})
  ";

  xdg.configFile."wal/templates/discord.css".text =
    "
    @import url('https://refact0r.github.io/system24/src/main.css'); /* main theme css. DO NOT REMOVE */
    
    :root {{
      
      /* background colors */
      --bg-0: {background}; /* main background color. */
      --bg-1: #1d2021; /* background color for secondary elements like code blocks, embeds, etc. */
      --bg-2: #3c3836; /* color of neutral buttons. */
      --bg-3: #504945; /* color of neutral buttons when hovered. */


      /* text colors */
      --txt-dark: var(--bg-0); /* color of dark text on colored backgrounds. */
      --txt-link: var(--aqua); /* color of links. */
      --txt-0: {foreground}; /* color of bright/white text. */
      --txt-1: {color1}; /* main text color. */
      --txt-2: {color3}; /* color of secondary text like channel list. */
      --txt-3: {color2}; /* color of muted text. */

      /* mention/ping and message colors */
      --red: {color1};
      --green: {color2};
      --yellow: {color3};
      --blue: {color4};
      --purple: {color5};
      --aqua: {color1};

      --font: 'JetBrainsMono Nerd Font';
      letter-spacing: -0.05ch;
      font-weight: 400;
      --label-font-weight: 500;
      --pad: 16px;
      --txt-pad: 10px;
      --panel-roundness: 12px;
      --hover: color-mix(in oklch, var(--txt-3), transparent 80%);
      --active: color-mix(in oklch, var(--txt-3), transparent 60%);
      --selected: var(--active);
      --mention-txt: var(--acc-0);
      --mention-bg: color-mix(in oklch, var(--acc-0), transparent 90%);
      --mention-overlay: color-mix(in oklch, var(--acc-0), transparent 90%);
      --mention-hover-overlay: color-mix(in oklch, var(--acc-0), transparent 95%);
      --reply-overlay: var(--active);
      --reply-hover-overlay: var(--hover);
      --acc-0: var(--aqua);
      --acc-1: var(--green);
      --acc-2: var(--blue);
      --border-width: 2px;
      --border-color: var(--bg-2);
      --border-hover-color: var(--acc-0);
      --border-transition: 0.2s ease;
      --online-dot: green;
      --dnd-dot: red;
      --idle-dot: yellow;
      --streaming-dot: purple;
    }}
  ";

  home.activation.symlink = lib.mkAfter "
    if [ ! -L ~/.config/vesktop/themes/discord.css ]; then
      ln -s ~/.cache/wal/discord.css ~/.config/vesktop/themes/discord.css
    fi
  ";
}
