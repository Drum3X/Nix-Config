{ ... }:
{
  wayland.windowManager.hyprland.settings = {
    group = {
      auto_group = true;
      insert_after_current = true;
      focus_removed_window = true;
      drag_into_group = 1;
      merge_groups_on_drag = true;
      merge_groups_on_groupbar = true;
      merge_floated_into_tiled_on_groupbar = false;
      group_on_movetoworkspace = false;
      "col.border_active" = "$secondary";
      "col.border_inactive" = "$background";
      "col.border_locked_active" = "$secondary";
      "col.border_locked_inactive" = "$background";
    };
  };
}
