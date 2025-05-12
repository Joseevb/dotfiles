#!/bin/bash

# Fetch location data
LOCATION_JSON=$(curl -s http://ip-api.com/json?fields=country,city)
LOCATION_COORDINATES_JSON=$(curl -s http://ip-api.com/json?fields=lat,lon)

LAT=$(echo $LOCATION_COORDINATES_JSON | jq -r .lat)
LON=$(echo $LOCATION_COORDINATES_JSON | jq -r .lon)
CITY=$(echo "$LOCATION_JSON" | jq -r .city | sed 's/ñ/n/g')
ENCODED_CITY=$(echo "$CITY" | sed 's/ /%20/g')

# Handle arguments
case "$1" in
    -c|--city)
        echo $CITY
        ;;
    -e|--encoded-city)
        echo $ENCODED_CITY
        ;;
    -lat|--latitude)
        echo $LAT
        ;;
    -lon|--longitude)
        echo $LON
        ;;
    -a|--all)
        echo "City: $CITY"
        echo "Latitude: $LAT"
        echo "Longitude: $LON"
        ;;
    *)
        echo "Usage: $0 {-c|--city | -e|--encoded-city | -lat|--latitude | -lon|--longitude | -a|--all}"
        exit 1
        ;;
esac
