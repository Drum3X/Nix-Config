{ pkgs, ... }:
{
  home.packages = [
    pkgs.libsForQt5.qt5ct
    pkgs.qt6ct
  ];

  qt = {
    enable = true;
    platformTheme.name = "qt5ct";
    style.name = "fusion";
  };

  xdg.configFile."qt5ct/qt5ct.conf".text = ''
    [Appearance]
    color_scheme_path=/home/drum3x/.config/qt5ct/colors/matugen.conf
    custom_palette=true
    standard_dialogs=gtk3

    [Fonts]
    fixed="UbuntuSans Nerd Font,11,-1,5,50,0,0,0,0,0"
    general="UbuntuSans Nerd Font,11,-1,5,50,0,0,0,0,0"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=1
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3

    [SettingsWindow]
    geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\x11\0\0\0J\0\0\x3\xb6\0\0\x4&\0\0\0\x11\0\0\0J\0\0\x3\xb6\0\0\x4&\0\0\0\0\0\0\0\0\a\x80\0\0\0\x11\0\0\0J\0\0\x3\xb6\0\0\x4&)

    [Troubleshooting]
    force_raster_widgets=1
    ignored_applications=@Invalid()
  '';

  xdg.configFile."qt6ct/qt6ct.conf".text = ''
    [Appearance]
    color_scheme_path=/home/drum3x/.config/qt6ct/colors/matugen.conf
    custom_palette=true
    standard_dialogs=gtk3

    [Fonts]
    fixed="UbuntuSans Nerd Font,11,-1,5,50,0,0,0,0,0"
    general="UbuntuSans Nerd Font,11,-1,5,50,0,0,0,0,0"

    [Interface]
    activate_item_on_single_click=1
    buttonbox_layout=0
    cursor_flash_time=1000
    dialog_buttons_have_icons=1
    double_click_interval=400
    gui_effects=@Invalid()
    keyboard_scheme=2
    menus_have_icons=true
    show_shortcuts_in_context_menus=true
    stylesheets=@Invalid()
    toolbutton_style=4
    underline_shortcut=1
    wheel_scroll_lines=3

    [SettingsWindow]
    geometry=@ByteArray(\x1\xd9\xd0\xcb\0\x3\0\0\0\0\0\x11\0\0\0J\0\0\x3\xb6\0\0\x4&\0\0\0\x11\0\0\0J\0\0\x3\xb6\0\0\x4&\0\0\0\0\0\0\0\0\a\x80\0\0\0\x11\0\0\0J\0\0\x3\xb6\0\0\x4&)

    [Troubleshooting]
    force_raster_widgets=1
    ignored_applications=@Invalid()
  '';
}
