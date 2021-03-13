#!/bin/sh

CUR=`pwd`
VER=0.3.52-1
rebuild_ipk() {
  rm -rf tmp && mkdir tmp && cd tmp
  tar -zxvf ${CUR}/$1

  if [ ! "$2" = "" ]; then
    mkdir data && cd data
    tar -zxvf ../data.tar.gz
    cp "$2" ./usr/sbin/linkease
    chmod 755 ./usr/sbin/linkease
    cd .. && rm -f data.tar.gz && tar -C ./data -zcvf data.tar.gz ./
    md5sum ./data/usr/sbin/linkease
  fi

  data_size=`stat --printf="%s" data.tar.gz`
  mkdir control && cd control
  tar -zxvf ../control.tar.gz
  sed -i "s/Version:.*/Version: ${VER}/g" ./control
  sed -i "s/Architecture:.*/Architecture: all/g" ./control
  sed -i "s/Installed-Size:.*/Installed-Size: ${data_size}/g" ./control
  echo "tar control"
  cd .. && tar -C ./control -zcvf control.tar.gz ./
  tar -zcvf $1 control.tar.gz data.tar.gz debian-binary
  cd ${CUR} && cp ./tmp/$1 ./
}

rm -f linkease_aarch64.ipk
rm -f linkease_arm.ipk
rm -f linkease_x86_64.ipk
wget https://firmware.koolshare.cn/binary/LinkEase/Openwrt/linkease_aarch64.ipk
wget https://firmware.koolshare.cn/binary/LinkEase/Openwrt/linkease_arm.ipk
wget https://firmware.koolshare.cn/binary/LinkEase/Openwrt/linkease_x86_64.ipk

BASE_DIR=/TODO
rebuild_ipk linkease_aarch64.ipk ${BASE_DIR}/raspi.arm64
rebuild_ipk linkease_arm.ipk ${BASE_DIR}/raspi.arm
rebuild_ipk linkease_arm.ipk ${BASE_DIR}/linkease.amd64

