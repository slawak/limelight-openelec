#!/bin/bash

#Settings
LIMELIGHT_DIR=/storage/downloads/limelight
JAVA_BIN=/storage/downloads/limelight/java
XBOXDRV_DIR=/storage/downloads/xboxdrv

HOST=192.168.10.16
BITRATE_720=15000
BITRATE_1080=20000
HDMI_MODE_720="CEA 4"
HDMI_MODE_1080="CEA 16"
INPUT=
MAPPING="-mapping limex360.conf"
DESKTOP_APP="Desktop"

#Defaults
RESOLUTION=720
BITRATE="$BITRATE_720"
HDMI_MODE="$HDMI_MODE_720"
FPS=60
APP=

EXIT_SUCCESS=0
EXIT_FAILURE=1

killoncec () {
    sleep 3
    python "$LIMELIGHT_DIR/killoncec.py"
}

startxboxdrv () {
    killall -q xboxdrv
    LD_LIBRARY_PATH="$XBOXDRV_DIR" "$XBOXDRV_DIR/xboxdrv" --trigger-as-button --id 0 --led 2 --detach-kernel-driver --deadzone 4000 --silent
}

prestream () {
    echo "Preparing to stream"
    # non working hack to try to set keyboard encoding right
    #loadkmap < "$LIMELIGHT_DIR/de-latin1-nodeadkeys.bmap"
    startxboxdrv &
    modprobe snd_bcm2835
    killoncec &
}

poststream () {
    echo "Cleaning up"
    killall -q xboxdrv
    killall -q python
    killall -q cec-client
    rmmod snd_bcm2835 ; sleep 1
    rmmod xpad ; sleep 1
    modprobe xpad ; sleep 1
}

run_limelight () {
    cd "$LIMELIGHT_DIR"
    "$JAVA_BIN" -jar limelight.jar "$@"
}

getrunning () {
    APP=$(run_limelight list $HOST | grep running | awk '{print substr($0, 2, length($0)-11)}')
}

listapps () {
    run_limelight list $HOST 
}

stream () {
    prestream
    sleep 1
    echo "Starting Limelight"
    echo "Server: $HOST, Resolution: $RESOLUTION, Framerate: $FPS, Bitrate: $BITRATE"
    if [ $# -gt 0 ]; then echo "Additional arguments: $@"; fi
    tvservice -e "$HDMI_MODE"
    run_limelight stream $HOST $INPUT $MAPPING -notest "-$RESOLUTION" "-${FPS}fps" -bitrate $BITRATE "$@"
    sleep 1
    poststream
}

resume () {
    echo "Trying to resume previous session"
    echo "Determining Running App"
    getrunning

    if [ -z "$APP" ]
    then
        echo "No Running App found. Starting Default App"
        stream
    else
        echo "Starting Limelight with $APP"
        stream -app "$APP"
    fi
}

desktop () {
    echo "Starting desktop session"
    stream -app "$DESKTOP_APP"
}

SCRIPTNAME=$(basename $0)
usage () {
 echo "Usage: $SCRIPTNAME [-720|-1080] [-r|--resume] [-d|--desktop] [-l|--list]" >&2
 [[ $# -eq 1 ]] && exit $1 || exit $EXIT_FAILURE
}

echo "Configuring Limelight"
echo "Parsing arguments"
while [ $# -gt 0 ]
do
    key="$1"
    case $key in
        -720)
        RESOLUTION=720
        BITRATE="$BITRATE_720"
        HDMI_MODE="$HDMI_MODE_720"
        ;;
        -1080)
        RESOLUTION=1080
        BITRATE="$BITRATE_1080"
        HDMI_MODE="$HDMI_MODE_1080"
        ;;
        -r|--resume)
        RESUME=YES
        ;;
        -d|--desktop)
        DESKTOP=YES
        ;;
        -l|--list)
        LIST=YES
        ;;
        *)
        UNKOWN_ARGUMENT="$key"
        ;;
    esac
    shift
done

if [ -n "$UNKOWN_ARGUMENT" ]
then
    echo "Unknown argument: $UNKOWN_ARGUMENT"
    usage
elif [[ "$LIST" == "YES" ]] 
then
    listapps
elif [[ "$DESKTOP" == "YES" ]] 
then
    desktop
elif [[ "$RESUME" == "YES" ]] 
then
    resume
else
    stream
fi

