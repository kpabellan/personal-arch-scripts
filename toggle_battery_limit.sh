#!/bin/bash

MODE="$1"

if [[ $MODE == "limit" ]]; then
  sudo sed -i 's/^START_CHARGE_THRESH_BAT0=.*/START_CHARGE_THRESH_BAT0=40/' /etc/tlp.conf
  sudo sed -i 's/^STOP_CHARGE_THRESH_BAT0=.*/STOP_CHARGE_THRESH_BAT0=80/' /etc/tlp.conf
  echo "Charge limit set to 80%"
elif [[ $MODE == "full" ]]; then
  sudo sed -i 's/^START_CHARGE_THRESH_BAT0=.*/START_CHARGE_THRESH_BAT0=95/' /etc/tlp.conf
  sudo sed -i 's/^STOP_CHARGE_THRESH_BAT0=.*/STOP_CHARGE_THRESH_BAT0=100/' /etc/tlp.conf
  echo "Charge limit set to 100%"
else
  echo "Usage: ./toggle_battery_limit.sh [limit|full]"
  exit 1
fi

sudo tlp start
