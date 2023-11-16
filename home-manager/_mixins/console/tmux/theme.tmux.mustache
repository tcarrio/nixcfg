#!/bin/bash
color__black="{{colors.black}}"
color__blue="{{colors.blue}}"
color__yellow="{{colors.yellow}}"
color__red="{{colors.red}}"
color__white="{{colors.white}}"
color__green="{{colors.green}}"
color__visual_grey="{{colors.visual_grey}}"
color__comment_grey="{{colors.comment_grey}}"

get() {
   local option=$1
   local default_value=$2
   local option_value="$(tmux show-option -gqv "$option")"

   if [ -z "$option_value" ]; then
      echo "$default_value"
   else
      echo "$option_value"
   fi
}

set() {
   local option=$1
   local value=$2
   tmux set-option -gq "$option" "$value"
}

setw() {
   local option=$1
   local value=$2
   tmux set-window-option -gq "$option" "$value"
}

set "status" "on"
set "status-justify" "left"

set "status-left-length" "100"
set "status-right-length" "100"
set "status-right-attr" "none"

set "message-fg" "$color__white"
set "message-bg" "$color__black"

set "message-command-fg" "$color__white"
set "message-command-bg" "$color__black"

set "status-attr" "none"
set "status-left-attr" "none"

setw "window-status-fg" "$color__black"
setw "window-status-bg" "$color__black"
setw "window-status-attr" "none"

setw "window-status-activity-bg" "$color__black"
setw "window-status-activity-fg" "$color__black"
setw "window-status-activity-attr" "none"

setw "window-status-separator" ""

set "window-style" "fg=$color__comment_grey"
set "window-active-style" "fg=$color__white"

set "pane-border-fg" "$color__white"
set "pane-border-bg" "$color__black"
set "pane-active-border-fg" "$color__green"
set "pane-active-border-bg" "$color__black"

set "display-panes-active-colour" "$color__yellow"
set "display-panes-colour" "$color__blue"

set "status-bg" "$color__black"
set "status-fg" "$color__white"

set "@prefix_highlight_fg" "$color__black"
set "@prefix_highlight_bg" "$color__green"
set "@prefix_highlight_copy_mode_attr" "fg=$color__black,bg=$color__green"
set "@prefix_highlight_output_prefix" "  "

status_widgets=$(get "@color__widgets")
time_format=$(get "@color__time_format" "%R")
date_format=$(get "@color__date_format" "%d/%m/%Y")

set "status-right" "#[fg=$color__white,bg=$color__black,nounderscore,noitalics]${time_format}  ${date_format} #[fg=$color__visual_grey,bg=$color__black]#[fg=$color__visual_grey,bg=$color__visual_grey]#[fg=$color__white, bg=$color__visual_grey]${status_widgets} #[fg=$color__green,bg=$color__visual_grey,nobold,nounderscore,noitalics]#[fg=$color__black,bg=$color__green,bold] #h #[fg=$color__yellow, bg=$color__green]#[fg=$color__red,bg=$color__yellow]"
set "status-left" "#[fg=$color__black,bg=$color__green,bold] #S #{prefix_highlight}#[fg=$color__green,bg=$color__black,nobold,nounderscore,noitalics]"

set "window-status-format" "#[fg=$color__black,bg=$color__black,nobold,nounderscore,noitalics]#[fg=$color__white,bg=$color__black] #I  #W #[fg=$color__black,bg=$color__black,nobold,nounderscore,noitalics]"
set "window-status-current-format" "#[fg=$color__black,bg=$color__visual_grey,nobold,nounderscore,noitalics]#[fg=$color__white,bg=$color__visual_grey,nobold] #I  #W #[fg=$color__visual_grey,bg=$color__black,nobold,nounderscore,noitalics]"
