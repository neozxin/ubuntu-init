#!/bin/sh
while true; do
  printf -- "\n================ 清理 VM 空间: 2.0.180903 ================\n"
  printf -- "\nBetter close everything before you continue, as any file content changes may cause execution fails\n"
  read -p "Is this for a VirualBox VM (y/n)? " var_VirtualBoxBased
  set -x
  sudo dd if=/dev/zero of=/EMPTY bs=1M
  sudo rm -f /EMPTY
  set +x
  [ "y" = "${var_VirtualBoxBased}" ] && {
    printf -- "\nShut down this VM and then run below command in host machine to minify the VM file: "
    printf -- '\n"\Program Files\Oracle\VirtualBox\VBoxManage.exe" modifyhd *.vdi --compact\n'
  }
  break
done
