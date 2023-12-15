#!/usr/bin/env sh

sudo {{bin.yabai}} --load-sa
{{bin.yabai}} -m signal --add event=dock_did_restart action="sudo {{bin.yabai}} --load-sa"

# global settings
# {{bin.yabai}} -m config mouse_follows_focus          on
# {{bin.yabai}} -m config focus_follows_mouse          off
{{bin.yabai}} -m config mouse_follows_focus          off
{{bin.yabai}} -m config focus_follows_mouse          autofocus
{{bin.yabai}} -m config window_placement             first_child
{{bin.yabai}} -m config window_topmost               off
{{bin.yabai}} -m config window_shadow                off
{{bin.yabai}} -m config window_opacity               on
{{bin.yabai}} -m config window_opacity_duration      0.0
{{bin.yabai}} -m config active_window_opacity        1
{{bin.yabai}} -m config normal_window_opacity        1
{{bin.yabai}} -m config window_border                on
{{bin.yabai}} -m config window_border_width          2
{{bin.yabai}} -m config window_border_radius         0
{{bin.yabai}} -m config active_window_border_color   0xFF88C0D0
{{bin.yabai}} -m config normal_window_border_color   on
{{bin.yabai}} -m config insert_feedback_color        0xff61afef
{{bin.yabai}} -m config split_ratio                  0.50
{{bin.yabai}} -m config auto_balance                 on
{{bin.yabai}} -m config mouse_modifier               fn
{{bin.yabai}} -m config mouse_action1                move
{{bin.yabai}} -m config mouse_action2                resize
{{bin.yabai}} -m config mouse_drop_action            swap

{{bin.yabai}} -m config layout                       bsp
{{bin.yabai}} -m config top_padding                  25
{{bin.yabai}} -m config bottom_padding               2
{{bin.yabai}} -m config left_padding                 2 
{{bin.yabai}} -m config right_padding                2
{{bin.yabai}} -m config window_gap                   1

# {{bin.yabai}} -m space 1 --label 1
# {{bin.yabai}} -m space 2 --label 2
# {{bin.yabai}} -m space 3 --label 3
# {{bin.yabai}} -m space 4 --label 4
# {{bin.yabai}} -m space 5 --label 5
# {{bin.yabai}} -m space 6 --label 6
# {{bin.yabai}} -m space 7 --label 7
# {{bin.yabai}} -m space 8 --label 8
# {{bin.yabai}} -m space 9 --label 9
# {{bin.yabai}} -m space 10 --label 10
#
# {{bin.yabai}} -m rule --add app="Code" space=1
# {{bin.yabai}} -m rule --add app="Firefox" space=2

### Sketchybar ###
{{bin.yabai}} -m signal --add event=window_focused action="sketchybar --trigger window_focus"         # Notify sketchybar when space changes
{{bin.yabai}} -m signal --add event=window_title_changed action="sketchybar --trigger title_change"   # Notify sketchybar when the focused app changes