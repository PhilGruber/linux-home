#!/bin/sh

export XAUTHORITY=/home/philipp/.Xauthority
export DISPLAY=:0

XR=`xrandr --display $DISPLAY | grep ' connected' | grep -v eDP-1`
EXT_SCREEN=`echo $XR | cut -d' ' -f1`
EXT_RESOLUTION=`echo $XR | cut -d' ' -f3 | sed 's/\+.*$//g'`
EXT_RESOLUTION_X=`echo $EXT_RESOLUTION | sed 's/x.*$//g'`

xrandr \
    --display "$DISPLAY" \
    --output eDP-1  --mode 1920x1080 --pos 0x0 --rotate normal \
    --output $EXT_SCREEN --mode $EXT_RESOLUTION --pos 1920x0 --rotate normal

sleep 3

XFCE_PID=$(ps -C xfce4-session -o pid= | sed 's/ //g')
export $(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$XFCE_PID/environ)

su philipp -c "xfconf-query -c xfce4-panel -p /panels/panel-2/autohide-behavior -s 0"
su philipp -c "xfconf-query -c xfce4-panel -p /plugins/plugin-3/include-all-monitors -s true"
su philipp -c "xfconf-query -c xfce4-panel -p /plugins/plugin-14/include-all-monitors -s true"
su philipp -c "xfconf-query -c xfce4-panel -p /plugins/plugin-3/include-all-monitors -s false"
su philipp -c "xfconf-query -c xfce4-panel -p /plugins/plugin-14/include-all-monitors -s false"
