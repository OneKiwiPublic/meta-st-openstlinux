#!/bin/sh
function print_debug() {
    echo "[exec]: $@"
}

function pty_exec() {
    cmd=$1
    pty=$(tty > /dev/null 2>&1; echo $?)
    if [ $pty -eq 0 ]; then
        cmd=$(echo $cmd | sed "s#\"#'#g")
        event_cmd=$(echo /usr/local/demo/bin/touch-event-gtk-player -w $SCREEN_WIDTH -h $SCREEN_HEIGHT --graph \"$cmd\")
        eval $event_cmd > /dev/null 2>&1
    else
        # no pty
        echo "NO PTY"
        event_cmd=$(echo /usr/local/demo/bin/touch-event-gtk-player -w $SCREEN_WIDTH -h $SCREEN_HEIGHT --graph \'$cmd\')
        script -qc "$event_cmd" > /dev/null 2>&1
    fi
}


is_dcmipp_present() {
    DCMIPP_SENSOR="NOTFOUND"
    # on disco board ov5640 camera can be present on csi connector
    for video in $(find /sys/class/video4linux -name "video*" -type l);
    do
        if [ "$(cat $video/name)" = "dcmipp_dump_capture" ]; then
            cd $video/device/
            mediadev=/dev/$(ls -d media*)
            cd -
            for sub in $(find /sys/class/video4linux -name "v4l-subdev*" -type l);
            do
                subdev_name=$(tr -d '\0' < $sub/name | awk '{print $1}')
                if [ "$subdev_name" = "gc2145" ] || [ "$subdev_name" = "ov5640" ]; then
                    DCMIPP_SENSOR=$subdev_name
                    V4L_DEVICE="device=/dev/$(basename $video)"
                    sensorsubdev=$(tr -d '\0' < $sub/name)
                    #bridge is connected to output of sensor (":0 [ENABLED" with media-ctl -p)
                    bridgesubdev=$(media-ctl -d $mediadev -p -e "$sensorsubdev" | grep ":0 \[ENABLED" | awk -F\" '{print $2}')
                    #interface is connected to input of postproc (":1 [ENABLED" with media-ctl -p)
                    interfacesubdev=$(media-ctl -d $mediadev -p -e "dcmipp_dump_postproc" | grep ":1 \[ENABLED" | awk -F\" '{print $2}')
                    if [ "$subdev_name" = "gc2145" ]; then
                        sensorbuscode_constrain="BE"
                        parallelbuscode="RGB565_2X8_BE"
                    else
                        sensorbuscode_constrain="LE"
                        parallelbuscode="RGB565_2X8_LE"
                    fi
                    echo "media device: "$mediadev
                    echo "video device: "$V4L_DEVICE
                    echo "sensor    subdev: " $sensorsubdev
                    echo "bridge    subdev: " $bridgesubdev
                    echo "interface subdev: " $interfacesubdev

                    return
                fi
            done
        fi
    done
}

is_dcmi_present() {
    DCMI_SENSOR="NOTFOUND"
    # on disco board ov5640 camera can be present on // connector
    for video in $(find /sys/class/video4linux -name "video*" -type l);
    do
        if [ "$(cat $video/name)" = "stm32_dcmi" ]; then
            V4L_DEVICE="device=/dev/$(basename $video)"
            DCMI_SENSOR="$(basename $video)"
            echo "video DCMI device: "$V4L_DEVICE
            return
        fi
    done
}

get_webcam_device() {
    found="NOTFOUND"
    for video in $(find /sys/class/video4linux -name "video*" -type l | sort);
    do
        if [ "$(cat $video/name)" = "dcmipp_dump_capture" ]; then
            found="FOUND"
        else
            V4L_DEVICE="device=/dev/$(basename $video)"
            break;
        fi
    done
}

# ------------------------------
#         main
# ------------------------------

# graphic brackend detection
if [ -f /etc/default/weston ] && $(grep "^OPTARGS" /etc/default/weston | grep -q "use-pixman" ) ;
then
	echo "Without GPU"
	ADDONS="videoconvert ! queue !"
else
	echo "With GPU"
	ADDONS=""
fi


# Detect size of screen
SCREEN_WIDTH=$(wayland-info | grep logical_width | sed -r "s/logical_width: ([0-9]+),.*/\1/")
SCREEN_HEIGHT=$(wayland-info | grep logical_width | sed -r "s/.*logical_height: ([0-9]+).*/\1/")


# camera detection
is_dcmipp_present
if [ "$DCMIPP_SENSOR" != "NOTFOUND" ]; then
    WIDTH=640
    HEIGHT=480
    FPS=30

    sensordev=$(media-ctl -d $mediadev -p -e "$sensorsubdev" | grep "node name" | awk -F\name '{print $2}')
    sensorbuscode=`v4l2-ctl --list-subdev-mbus-codes -d $sensordev | grep RGB565 | grep "$sensorbuscode_constrain" | awk -FMEDIA_BUS_FMT_ '{print $2}'| head -n 1`
    echo "sensor mbus-code: "$sensorbuscode
    print_debug media-ctl -d $mediadev --set-v4l2 "'$sensorsubdev':0[fmt:$sensorbuscode/${WIDTH}x${HEIGHT}@1/${FPS} field:none]"
    media-ctl -d $mediadev --set-v4l2 "'$sensorsubdev':0[fmt:$sensorbuscode/${WIDTH}x${HEIGHT}@1/${FPS} field:none]"
    print_debug media-ctl -d $mediadev --set-v4l2 "'$bridgesubdev':2[fmt:$sensorbuscode/${WIDTH}x${HEIGHT}]"
    media-ctl -d $mediadev --set-v4l2 "'$bridgesubdev':2[fmt:$sensorbuscode/${WIDTH}x${HEIGHT}]"
    print_debug media-ctl -d $mediadev --set-v4l2 "'$interfacesubdev':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    media-ctl -d $mediadev --set-v4l2 "'$interfacesubdev':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    print_debug media-ctl -d $mediadev --set-v4l2 "'dcmipp_dump_postproc':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    media-ctl -d $mediadev --set-v4l2 "'dcmipp_dump_postproc':1[fmt:$parallelbuscode/${WIDTH}x${HEIGHT}]"
    V4L2_CAPS="video/x-raw, format=RGB16, width=$WIDTH, height=$HEIGHT"
    V4L_OPT=""

else
    is_dcmi_present
    if [ "$DCMI_SENSOR" != "NOTFOUND" ]; then
        COMPATIBLE_BOARD=$(cat /proc/device-tree/compatible | sed "s|st,|,|g" | cut -d ',' -f2)
        case $COMPATIBLE_BOARD in
        stm32mp15*)
            WIDTH=320
            HEIGHT=240
            ;;
        *)
            WIDTH=640
            HEIGHT=480
            ;;
        esac
    else
        get_webcam_device
        # suppose we have a webcam
        WIDTH=640
        HEIGHT=480
    fi

    V4L2_CAPS="video/x-raw, width=$WIDTH, height=$HEIGHT"
    V4L_OPT="io-mode=4"
    v4l2-ctl --set-parm=30
fi


echo "Gstreamer graph:"
GRAPH="v4l2src $V4L_DEVICE $V4L_OPT ! $V4L2_CAPS ! queue ! $ADDONS gtkwaylandsink name=gtkwsink"

echo "  $GRAPH"
pty_exec "$GRAPH"
