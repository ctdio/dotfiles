#!/bin/bash
set -e

TIMEOUT=5

COORDINATES="$(curl -s --max-time $TIMEOUT  http://whatismycountry.com | \
  sed -n '/Coordinates/p' | \
  sed -n 's/<p>//p' | \
  sed -n 's/<\/p>//p' | \
  sed -n 's/Coordinates //p' | \
  sed -n 's/ /,/p')"

curl --max-time $TIMEOUT wttr.in/$COORDINATES
