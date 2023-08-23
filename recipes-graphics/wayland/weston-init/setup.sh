#!/bin/sh
BASE_DIR=/usr/local
HOME_DIR=/home/root

echo "Extracting V3.4"
cd  $HOME_DIR
tar -xf V3.4.tar.gz
rm V3.4.tar.gz

echo "Copy app and extracting"
#mv $HOME_DIR/linuxapp.tar.gz $HOME_DIR/remoteit.tar.gz $BASE_DIR
mv $HOME_DIR/*.tar.gz $BASE_DIR

echo "Move to app dir"
cd  $BASE_DIR
tar -xf linuxapp.tar.gz
tar -xf bin.tar.gz -C linuxapp/
tar -xf lib_ffplay.tar.gz -C linuxapp/

#echo "Extract remoteit package"
#tar -xf remoteit.tar.gz

echo "Update new config file"
mv $HOME_DIR/config.db $BASE_DIR/linuxapp/bin

echo "========================="