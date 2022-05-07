#!/bin/bash

if [[ "$(uname)" = 'Linux' ]]; then
  echo "Detected Linux"
  echo "Setting key repeat and delay rate"
  xset r rate 220 60
elif [[ "$(uname)" = 'Darwin' ]]; then
  echo "Detected Linux"
  echo "Loading yabai scripting edition..."
  sudo yabai --load-sa
fi

echo "Completed startup!"
