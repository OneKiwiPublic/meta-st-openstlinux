#!/bin/sh
BASE_DIR=/usr/local
HOME_DIR=/home/root

echo "Copy app and extracting"
#mv $HOME_DIR/linuxapp.tar.gz $HOME_DIR/remoteit.tar.gz $BASE_DIR
mv $HOME_DIR/linuxapp.tar.gz $BASE_DIR

echo "Move to app dir"
cd  $BASE_DIR
tar -xf linuxapp.tar.gz

#echo "Extract remoteit package"
#tar -xf remoteit.tar.gz

echo "Update new config file"
mv $HOME_DIR/config.db $BASE_DIR/linuxapp/bin

echo "Move to service dir"
cd $BASE_DIR/linuxapp/service

echo "Run deploy script"
./deploy-script.sh

#echo "Setup remoteit"
#cd $BASE_DIR/remoteit
#./install.sh

echo "========================="