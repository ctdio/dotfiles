#!/bin/bash

SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9" "10")

for i in "${!SPACE_ICONS[@]}"
do
  sid=$(($i+1))
  sketchybar --add space space.$sid left                                 \
             --set space.$sid associated_space=$sid                      \
                              icon=${SPACE_ICONS[i]}                     \
                              background.color=0x44ffffff                \
                              background.corner_radius=5                 \
                              background.height=20                       \
                              background.drawing=off                     \
                              label.drawing=off                          \
                              script="$PLUGIN_DIR/space.sh"              \
                              click_script="yabai -m space --focus $sid"
done



##### Adding Left Items #####
# We add some regular items to the left side of the bar
# only the properties deviating from the current defaults need to be set

sketchybar --add item space_separator left                         \
           --set space_separator icon=                            \
                                 padding_left=10                   \
                                 padding_right=10                  \
                                 label.drawing=off
