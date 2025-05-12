#!/bin/bash

madrid_time=$(TZ="Europe/Madrid" date "+%H:%M %Z")
caracas_time=$(TZ="America/Caracas" date "+%H:%M %Z")

echo -e "{\"text\": \" $(date +%H:%M)\", \"tooltip\": \"Madrid: $madrid_time\nCaracas: $caracas_time\"}"
