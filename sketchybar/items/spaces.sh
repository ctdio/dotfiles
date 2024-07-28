#!/bin/bash

sketchybar --add event aerospace_workspace_change

for sid in $(aerospace list-workspaces --all); do
    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change          \
        --set space.$sid background.color=0x44ffffff               \
                         background.corner_radius=5                \
                         background.height=20                      \
                         background.drawing=off                    \
                         label.drawing=off                         \
                         icon="$sid"                               \
                         click_script="aerospace workspace $sid"   \
                         script="$CONFIG_DIR/plugins/space.sh $sid"
done


##### Adding Left Items #####
# We add some regular items to the left side of the bar
# only the properties deviating from the current defaults need to be set

sketchybar --add item space_separator left                         \
           --set space_separator icon=                            \
                                 padding_left=10                   \
                                 padding_right=10                  \
                                 label.drawing=off
