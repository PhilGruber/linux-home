#!/bin/sh

date >> /tmp/screen.log
echo "running screen.sh" >> /tmp/screen.log

export XAUTHORITY=/home/philipp/.Xauthority
export DISPLAY=:0

XR=`xrandr --display $DISPLAY | grep ' connected' | grep -v eDP-1`
EXT_SCREEN=`echo $XR | cut -d' ' -f1`
EXT_RESOLUTION=`echo $XR | cut -d' ' -f3 | sed 's/\+.*$//g'`
EXT_RESOLUTION_X=`echo $EXT_RESOLUTION | sed 's/x.*$//g'`
MAX_RESOLUTION=`xrandr --display $DISPLAY | grep $EXT_SCREEN -A5 | grep -v "^$EXT_SCREEN" | sort | tail -n1 | cut -d' ' -f4`
MAX_RESOLUTION_X=`echo $MAX_RESOLUTION | sed 's/x.*$//g'`

xrandr \
    --display "$DISPLAY" \
    --output $EXT_SCREEN --mode $MAX_RESOLUTION --pos 0x0 --rotate normal --scale 1x1 \
    --output eDP-1  --mode 1920x1080 --pos $MAX_RESOLUTION_X''x1422 --rotate normal --scale 0.9999x0.9999


XFCE_PID=$(ps -C xfce4-session -o pid= | sed 's/ //g')
export $(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$XFCE_PID/environ)

xfconf-query -c xfce4-panel -p /panels/panel-0/autohide-behavior -s 0
xfconf-query -c xfce4-panel -p /plugins/plugin-3/include-all-monitors -s true
xfconf-query -c xfce4-panel -p /plugins/plugin-13/include-all-monitors -s true
xfconf-query -c xfce4-panel -p /plugins/plugin-3/include-all-monitors -s false
xfconf-query -c xfce4-panel -p /plugins/plugin-13/include-all-monitors -s false
