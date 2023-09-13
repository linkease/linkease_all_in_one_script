#!/bin/sh

version="1.0"
APP_BIN='/usr/local/bin/linkease'
APP_URL='http://fw.koolcenter.com/binary/LinkEase/AutoUpgrade'
app_aarch64='raspi.arm64'
app_arm='raspi.arm'

setup_color() {
    # Only use colors if connected to a terminal
    if [ -t 1 ]; then
        RED=$(printf '\033[31m')
        GREEN=$(printf '\033[32m')
        YELLOW=$(printf '\033[33m')
        BLUE=$(printf '\033[34m')
        BOLD=$(printf '\033[1m')
        RESET=$(printf '\033[m')
    else
        RED=""
        GREEN=""
        YELLOW=""
        BLUE=""
        BOLD=""
        RESET=""
    fi
}
setup_color
command_exists() {
    command -v "$@" >/dev/null 2>&1
}
error() {
    echo ${RED}"Error: $@"${RESET} >&2
}

Download_Files(){
  local URL=$1
  local FileName=$2
  if command_exists curl; then
    curl -sSLk ${URL} -o ${FileName}
  elif command_exists wget; then
    wget -c --no-check-certificate ${URL} -O ${FileName}
  fi
  if [ $? -eq 0 ]; then
    echo "Download OK"
  else
    echo "Download failed"
    exit 1
  fi
}

clean_app(){
    rm -f /tmp/${app_arm} /tmp/${app_aarch64}
}

systemctl stop com.linkease.linkeasedaemon.service || true

if echo `uname -m` | grep -Eqi 'x86_64'; then
    arch='x86_64'
    ( set -x; echo "upgrade not supported in x86"; )
elif  echo `uname -m` | grep -Eqi 'arm'; then
    arch='arm'
    ( set -x; Download_Files ${APP_URL}/${app_arm} /tmp/${app_arm};
      cp /tmp/${app_arm} ${APP_BIN}; )
elif  echo `uname -m` | grep -Eqi 'aarch64'; then
    arch='aarch64'
    ( set -x; Download_Files ${APP_URL}/${app_aarch64} /tmp/${app_aarch64};
      cp /tmp/${app_aarch64} ${APP_BIN}; )
elif  echo `uname -m` | grep -Eqi 'mips|mipsel'; then
    error "The program not support mips."
    exit 1
else
    error "The program only supports HNAS."
    exit 1
fi

echo "The linkease version is:"
${APP_BIN} showVersion

if [ $? -eq 0 ]; then
  echo "Upgrade OK"
else
  clean_app
  echo "Upgrade failed(安装失败)"
  exit 2
fi

printf "$GREEN"
cat <<-'EOF'
  linkease is now upgraded!


  安装成功，请到 https://www.linkease.com/ 获取更多帮助

EOF
printf "$RESET"
clean_app
systemctl start com.linkease.linkeasedaemon.service || true
