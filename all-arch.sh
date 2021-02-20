#!/bin/sh

CUR=`pwd`
rm -rf tmp && mkdir tmp && cd tmp
tar -zxvf ${CUR}/$1
mkdir control && cd control
tar -zxvf ../control.tar.gz
sed -i "s/Architecture:.*/Architecture: all/g" ./control
echo "tar control"
tar -zcvf control.tar.gz ./control  ./postinst  ./postinst-pkg  ./prerm
mv control.tar.gz .. && cd ..
tar -zcvf $1 control.tar.gz data.tar.gz debian-binary
cd ${CUR} && cp ./tmp/$1 ./

