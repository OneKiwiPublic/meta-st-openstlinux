#!/bin/sh
BASE_DIR=/usr/local
HOME_DIR=/home/root

echo "Extracting V3.4"
cd  $HOME_DIR
tar -xf V3.4.tar.gz
chmod +x V3.4/app_installer.sh
rm V3.4.tar.gz

echo "Copy app and extracting"
#mv $HOME_DIR/linuxapp.tar.gz $HOME_DIR/remoteit.tar.gz $BASE_DIR
mv $HOME_DIR/*.tar.gz $BASE_DIR

echo "Move to app dir"
cd  $BASE_DIR
tar -xf linuxapp.tar.gz
tar -xf bin.tar.gz -C linuxapp/
tar -xf lib_ffplay1.tar.gz -C linuxapp/
tar -xf lib_ffplay2.tar.gz -C linuxapp/
mv linuxapp/lib_ffplay1/ linuxapp/lib_ffplay/
mv linuxapp/lib_ffplay2/* linuxapp/lib_ffplay
rm -rf linuxapp/lib_ffplay2
rm *.tar.gz
cd  $HOME_DIR

#echo "Update new config file"
#mv $HOME_DIR/config.db $BASE_DIR/linuxapp/bin

echo "========================="