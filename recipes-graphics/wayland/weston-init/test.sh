#!/bin/sh

### Check if a directory does not exist ###
if [ -f "setup.sh" ]; then
    ./setup.sh
    rm setup.sh
fi

#!/bin/sh

### Check if a directory does not exist ###
INSTALLER_FILE=/home/root/V3.4/app_installer.sh
if [ -f $INSTALLER_FILE ]; then
    $INSTALLER_FILE
fi


echo "1. test led:"
ls /sys/class/leds
echo 0 > /sys/class/leds/led-r/brightness
echo 0 > /sys/class/leds/led-g/brightness
echo 0 > /sys/class/leds/led-b/brightness
sleep 1

echo "2. test uart:"
ls /dev/ttySTM*

echo "3. test i2c codec:"
i2cdetect -y 0

echo "4. test i2c pmic:"
i2cdetect -y 3

echo "5. test uSD Card:"
cat /proc/partitions | grep mmcblk0

echo "6. test audio:"
#aplay -D plughw:CARD=STM32MP15DK /home/root/somewhere.wav
#amixer -q -D pulse sset Master 30%; aplay /home/root/somewhere.wav &
#echo 0 > /sys/class/leds/audio-s0/brightness
#echo 1 > /sys/class/leds/audio-s1/brightness
/usr/local/linuxapp/bin/audio_4g_on.sh

R=$(($$%2))
echo $R
M=0
if [ $R -eq $M ];then
    amixer -q -D pulse sset Master 30%; aplay /home/root/somewhere.wav &
else
    amixer -q -D pulse sset Master 30%; aplay /home/root/autumn-in-my-heart.wav &
fi

#echo "7. test 4G:"
#/usr/local/linuxapp/bin/reset-4g

echo "7. test ethernet:"
ifconfig

/usr/local/linuxapp/bin/audio_all_off.sh
