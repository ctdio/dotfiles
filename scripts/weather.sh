#!/bin/bash
set -e

COORDINATES="$(curl -s http://whatismycountry.com | \
  sed -n '/Coordinates/p' | \
  sed -n 's/<p>//p' | \
  sed -n 's/<\/p>//p' | \
  sed -n 's/Coordinates //p' | \
  sed -n 's/ /,/p')"

curl wttr.in/$COORDINATES
