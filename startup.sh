#!/bin/bash

if [[ "$(uname)" = 'Linux' ]]; then
  echo "Detected Linux"
  echo "Setting key repeat and delay rate"
  xset r rate 220 60
elif [[ "$(uname)" = 'Darwin' ]]; then
  echo "Detected MacOs"
  echo "Loading aerospace and sketchybar..."
  aerospace enable on
  sketchybar --reload
fi

echo "Completed startup!"
