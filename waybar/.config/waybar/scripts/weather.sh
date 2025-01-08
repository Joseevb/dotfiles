#!/bin/bash

REGULAR_OUTPUT=$(bash /home/jose/.config/waybar/scripts/get-current-weather.sh)
TOOLTIP_OUTPUT=$(bash /home/jose/.config/waybar/scripts/get-current-weather-full.sh)

echo "$REGULAR_OUTPUT | $TOOLTIP_OUTPUT"
