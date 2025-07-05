# LOCATION_JSON=$(curl -s http://ip-api.com/json?fields=country,city)
# LOCATION_COORDINATES_JSON=$(curl -s http://ip-api.com/json?fields=lat,lon)
#
# LAT=$(echo $LOCATION_COORDINATES_JSON | jq -r .lat)
# LON=$(echo $LOCATION_COORDINATES_JSON | jq -r .lon) CITY=$(echo $LOCATION_JSON | jq -r .city)
#
# ENCODED_CITY=$(echo "$CITY" | sed 's/ /%20/g')
#
# WEATHER=$(../tools/wttrbar/target/release/wttrbar --location "$CITY")
# # TOOLTIP=$(echo $WEATHER)
#
# echo $WEATHER

#!/bin/bash



LOCATION=$(sh /home/jose/.config/waybar/scripts/get-current-location.sh -c)
WEATHER=$(wttrbar --location "$LOCATION")

echo $WEATHER
