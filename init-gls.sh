#!/bin/sh
## ================ GLS Init Scripts: 1.0.190110 ================
printArgs() {
  local IFS="|"
  printf -- "\nCommand arguments separated by '|': $*\n"
}
enterOrDefault() {
  local var_prompt="$1"
  local var_default="$2"
  local var_var
  read -p "${var_prompt} [${var_default}]: " var_var
  printf -- "${var_var:-"${var_default}"}"
}

init__GlsServer_launch() {
  printf -- "\n[$(date) @ X] Info: init GLS Server - Launch Server\n" \
  && {
    local f && for f in "dockerimg@gls@server"*; do cat "$f" | docker load; done
    docker run -d --restart=unless-stopped \
     --name "gls-server-x" \
     --privileged=true --net=host \
     -v /usr/my-gls-volumes.dir:/usr/my-gls-volumes.dir \
     -v /etc/glusterfs:/etc/glusterfs:z \
     -v /var/lib/glusterd:/var/lib/glusterd:z \
     -v /var/log/glusterfs:/var/log/glusterfs:z \
     -v /sys/fs/cgroup:/sys/fs/cgroup:ro \
     -v /dev/:/dev \
     "gluster/gluster-centos:gluster4u0_centos7"
  } \
  || return 1
}

init__GlsServer_probe() {
  printf -- "\n[$(date) @ X] Info: init GLS Server - Probe Peers\n" \
  && {
    local IFS="|"
    local var_PeerServerNames="$2"
    local var_PeerServerName
    [ -n "${var_PeerServerNames}" ] && {
      for var_PeerServerName in ${var_PeerServerNames}; do
        docker exec -i "gls-server-x" gluster peer probe "${var_PeerServerName}" || break
        var_PeerServerName=""
      done
      [ -z "${var_PeerServerName}" ] && return || return 1
    }
    while true; do
      var_PeerServerName="$(enterOrDefault "Please enter a peer server name(empty to finish)")"
      [ -z "${var_PeerServerName}" ] && break
      docker exec -it "gls-server-x" gluster peer probe "${var_PeerServerName}" || break
    done
    [ -z "${var_PeerServerName}" ]
  } \
  || return 1
}

init__GlsServer_volume() {
  printf -- "\n[$(date) @ X] Info: init GLS Server - Create and Start Volume\n" \
  && {
    local IFS="|"
    local var_PeerServerVolumes
    local var_PeerServerCount=0
    local var_VolumeName="$2"
    local var_PeerServerNames="$3"
    local var_PeerServerName
    [ -z "${var_VolumeName}" ] && var_VolumeName="$(enterOrDefault "Please enter volume name" "gls-volume_main")"
    [ -z "${var_PeerServerNames}" ] && var_PeerServerNames="$(enterOrDefault "Please enter all peer server names(format: 'server1name|server2name|server3name')")"
    for var_PeerServerName in ${var_PeerServerNames}; do
      var_PeerServerVolumes="${var_PeerServerVolumes:+"${var_PeerServerVolumes}|"}${var_PeerServerName}:/usr/my-gls-volumes.dir/${var_VolumeName}.dir"
      var_PeerServerCount=$((${var_PeerServerCount}+1))
    done
    # var_PeerServerVolumes="$(enterOrDefault "Please enter peer server volumes(format: 'server1name:server1path|server2name:server2path|server3name:server3path')")"
    # local i && for i in ${var_PeerServerVolumes}; do var_PeerServerCount=$((${var_PeerServerCount}+1)); done
    set -x
    docker exec -it "gls-server-x" gluster volume create "${var_VolumeName}" replica "${var_PeerServerCount}" ${var_PeerServerVolumes} force \
    && docker exec -it "gls-server-x" gluster volume start "${var_VolumeName}"
  } \
  || return 1
}

init__GlsClient_install() {
  printf -- "\n[$(date) @ X] Info: init GLS Client - Install Client Volume\n" \
  && {
    apt-get install -y glusterfs-client
    glusterfs --help
  } \
  || return 1
}

init__GlsClient_mount() {
  printf -- "\n[$(date) @ X] Info: init GLS Client - Mount Volume\n" \
  && {
    local var_PeerServerName="$2"
    local var_VolumeName="$3"
    local var_LocalMountPath="$4"
    [ -z "${var_PeerServerName}" ] && var_PeerServerName="$(enterOrDefault "Please enter a peer server name" "gls-server-1")"
    [ -z "${var_VolumeName}" ] && var_VolumeName="$(enterOrDefault "Please enter volume name" "gls-volume_main")"
    [ -z "${var_LocalMountPath}" ] && var_LocalMountPath="$(enterOrDefault "Please enter local path to mount" "/mnt")"
    mount -t glusterfs "${var_PeerServerName}":/"${var_VolumeName}" "${var_LocalMountPath}"
  } \
  || return 1
}

init__GlsClient_unmount() {
  printf -- "\n[$(date) @ X] Info: init GLS Client - Unmount Volume\n" \
  && {
    local var_LocalMountPath="$(enterOrDefault "Please enter local path to mount" "/mnt")"
    umount "${var_LocalMountPath}"
  } \
  || return 1
}

init__GlsRemote_resetservers() {
  printf -- "\n[$(date) @ X] Info: init GLS Remote - Reset Servers\n" \
  && {
    printf -- 'You might need to ensure line "$USER ALL=(ALL:ALL) NOPASSWD: ALL" present in visudo on remote server before running this\n'
    printf -- "Usage(example): $0 $1 'root@gls-server-1|root@gls-server-2|root@gls-server-3'\n"
    local IFS="|"
    local var_PeerServers="$2"
    local var_PeerServer
    local var_PeerServerNames
    for var_PeerServer in ${var_PeerServers}; do
      var_PeerServerNames="${var_PeerServerNames:+"${var_PeerServerNames}|"}${var_PeerServer#*@}"
      cat "$0" | ssh "${var_PeerServer}" 'sudo sh -s -- server.launch' || break
      var_PeerServer=""
    done
    [ -z "${var_PeerServer}" ] && {
      cat "$0" | ssh "${var_PeerServerNames%%|*}" "sudo sh -s -- server.probe '${var_PeerServerNames}'"
    }
  } \
  || return 1
}

main() {
  printArgs "$@"
  while true; do
    [ "server.launch" = "$1" ] && {
      init__GlsServer_launch "$@" || break
    }
    [ "server.probe" = "$1" ] && {
      init__GlsServer_probe "$@" || break
    }
    [ "server.volume" = "$1" ] && {
      init__GlsServer_volume "$@" || break
    }
    [ "client.install" = "$1" ] && {
      init__GlsClient_install "$@" || break
    }
    [ "client.mount" = "$1" ] && {
      init__GlsClient_mount "$@" || break
    }
    [ "remote.resetservers" = "$1" ] && {
      init__GlsRemote_resetservers "$@" || break
    }
    [ -z "$1" ] && {
      printf -- "\nUsage example: $0 remote.resetservers\n"
      printf -- "\nUsage example: $0 client.install\n"
      printf -- "\nUsage example: $0 client.mount\n"
    }
    printf -- "\n[$(date) @ X] Success!\n"
    return
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"
