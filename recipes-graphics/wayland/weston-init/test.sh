#!/bin/sh

### Check if a directory does not exist ###
if [ -f "setup.sh" ]; then
    ./setup.sh
    rm setup.sh
fi

echo "1. test led:"
ls /sys/class/leds
#led off
echo 1 > /sys/class/leds/led-r/brightness
echo 1 > /sys/class/leds/led-g/brightness
echo 1 > /sys/class/leds/led-b/brightness

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
echo 0 > /sys/class/leds/audio-s0/brightness
echo 1 > /sys/class/leds/audio-s1/brightness

R=$(($$%2))
echo $R
M=0
if [ $R -eq $M ];then
    amixer -q -D pulse sset Master 30%; aplay /home/root/somewhere.wav &
else
    amixer -q -D pulse sset Master 30%; aplay /home/root/autumn-in-my-heart.wav &
fi

echo "7. test ethernet:"
ifconfig

#led red on
echo 0 > /sys/class/leds/led-r/brightness
echo 1 > /sys/class/leds/led-g/brightness
echo 1 > /sys/class/leds/led-b/brightness
sleep 1

#led green on
echo 1 > /sys/class/leds/led-r/brightness
echo 0 > /sys/class/leds/led-g/brightness
echo 1 > /sys/class/leds/led-b/brightness
sleep 1

#led blue on
echo 1 > /sys/class/leds/led-r/brightness
echo 1 > /sys/class/leds/led-g/brightness
echo 0 > /sys/class/leds/led-b/brightness
sleep 1

#led off
echo 1 > /sys/class/leds/led-r/brightness
echo 1 > /sys/class/leds/led-g/brightness
echo 1 > /sys/class/leds/led-b/brightness

#off audio
#echo 0 > /sys/class/leds/audio-s0/brightness
#echo 0 > /sys/class/leds/audio-s1/brightness
