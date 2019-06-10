#!/bin/bash

# set resolution for laptop display
xrandr --output eDP-1 --mode 1920x1080

# set key repeat
xset r rate 220 40

# apply keybindings
xmodmap ~/.xmodmap
