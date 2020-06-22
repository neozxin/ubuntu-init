#!/bin/sh
## ================ CID Init Scripts: 2.0.200407 ================
var_jenkinsHomeDir="/var/jenkins_home"
var_jenkinsDockerImage="jenkins/jenkins:2.230"

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

init__CidServer_launch() {
  printf -- "\n[$(date) @ X] Info: init CID Server - Launch Server\n"
  local f && for f in "dockerimg@cid@"*; do cat "$f" | docker load; done
  local var_common_scriptdir="$(cd "$(dirname "$0")" && pwd)"
  local ENV_BUILD_SERVER_USER="$(whoami)"
  local ENV_BUILD_SERVER_HOST="$(hostname)"
  while true; do
    if [ "studio" = "$2" ]; then
      docker run -d --restart=unless-stopped \
        --name "jenkins-server" --net=host \
        -v "${var_common_scriptdir}":"/usr/src/0.host-share" \
        -v "jenkins_home":"${var_jenkinsHomeDir}" \
        -e "ENV_BUILD_SERVER_USER=${ENV_BUILD_SERVER_USER}" \
        -e "ENV_BUILD_SERVER_HOST=${ENV_BUILD_SERVER_HOST}" \
        "${var_jenkinsDockerImage}" \
      && printf -- "\nBrowse http://${ENV_BUILD_SERVER_HOST}:8080/ and make sure the server is started and up, then continue to setup step\n" \
      || break
    elif [ "complex" = "$2" ]; then
      # docker agent ref: https://www.cnblogs.com/leolztang/p/6934694.html
      docker run -d --restart=unless-stopped \
        --name "jenkins-server" --net=host -u root \
        -v "${var_common_scriptdir}":"/usr/src/0.host-share" \
        -v "jenkins_home":"${var_jenkinsHomeDir}" \
        -v "/var/run/docker.sock":"/var/run/docker.sock" \
        -v "$(which docker)":"/usr/bin/docker" \
        -v "/usr/lib/x86_64-linux-gnu/libltdl.so.7":"/usr/lib/x86_64-linux-gnu/libltdl.so.7" \
        -e "ENV_BUILD_SERVER_USER=${ENV_BUILD_SERVER_USER}" \
        -e "ENV_BUILD_SERVER_HOST=${ENV_BUILD_SERVER_HOST}" \
        "${var_jenkinsDockerImage}" \
      && printf -- "\nBrowse http://${ENV_BUILD_SERVER_HOST}:8080/ and make sure the server is started and up, then continue to setup step\n" \
      || break
    elif [ "deprecated.blueocean" = "$2" ]; then
      # ref: https://jenkins.io/doc/tutorials/build-a-node-js-and-react-app-with-npm/
      docker run -d --restart=unless-stopped \
        --name "jenkins-server" --net=host \
        -u root \
        -v "${var_common_scriptdir}":"/usr/src/0.host-share" \
        -v "jenkins_home":"${var_jenkinsHomeDir}" \
        -v "/var/run/docker.sock":"/var/run/docker.sock" \
        -v "$HOME":"/home" \
        "jenkinsci/blueocean:1.10.2" \
      && docker exec -it "jenkins-server" sh -c "jq &>/dev/null || apk add jq" \
      || break
    else
      printf -- "\nUsage example: $0 server.launch studio\n"
      printf -- "\nUsage example: $0 server.launch complex\n"
      break
    fi
    return
  done
  return 1
}

init__CidServer_setup() {
  printf -- "\n[$(date) @ X] Info: init CID Server - Setup Server\n" \
  && {
    docker exec -it "jenkins-server" sh -c "/usr/src/0.host-share/init-cid.sh script.jenkins.setup"
    # cat $0 | docker exec -i "jenkins-server" sh -s -- script.jenkins.setup
  } \
  || return 1
}

script__Jenkins_setup() {
  printf -- "\n[$(date) @ X] Info: script Jenkins Server - Setup\n" \
  && {
    ssh-keygen \
    && ssh-copy-id "${ENV_BUILD_SERVER_USER}@${ENV_BUILD_SERVER_HOST}" \
    && printf -- "\nFile content for ${var_jenkinsHomeDir}/secrets/initialAdminPassword in server as below:\n" \
    && cat "${var_jenkinsHomeDir}/secrets/initialAdminPassword"
    # local var_script='#!/bin/sh\n'
    # # var_script="${var_script}"'set -x\n'
    # var_script="${var_script}"'ssh-keygen\n'
    # var_script="${var_script}"'ssh-copy-id "${ENV_BUILD_SERVER_USER}@${ENV_BUILD_SERVER_HOST}"\n'
    # var_script="${var_script}"'echo "Browse http://${ENV_BUILD_SERVER_HOST}:8080/ and make sure the server is started and up, then press Enter here"\n'
    # var_script="${var_script}"'read\n'
    # var_script="${var_script}"'echo "File content for ${var_jenkinsHomeDir}/secrets/initialAdminPassword in server as below:"\n'
    # var_script="${var_script}"'cat "${var_jenkinsHomeDir}/secrets/initialAdminPassword"\n'
    # var_script="${var_script}"'\n'
    # docker exec -it "jenkins-server" sh -c "printf -- '${var_script}' > ~/setup-jenkins.sh" \
    # && docker exec -it "jenkins-server" sh -c "chmod 700 ~/setup-jenkins.sh" \
    # && docker exec -it "jenkins-server" sh -c "cat ~/setup-jenkins.sh" \
    # && docker exec -it "jenkins-server" sh -c "~/setup-jenkins.sh"
  } \
  || return 1
}

init__CidServer_backup() {
  printf -- "\n[$(date) @ X] Info: init CID Server - Backup Server data\n" \
  && {
    local var_backupDir="/usr/src/0.host-share/backups"
    local var_backupStamp="$(date -u +'%Y-%m-%dT%H-%M-%S')"
    local var_backupJenkinsHomeFilename="jenkins_home_BAK${var_backupStamp}UTC.tar.gz"
    read -p $'Jenkins Server will be stopped for backup and then restarted, continue? (y/n) ' var_common_confirmationkey \
    && [ 'y' = "${var_common_confirmationkey}" ] \
    && docker stop "jenkins-server" \
    && docker run --rm -u root --volumes-from "jenkins-server" "${var_jenkinsDockerImage}" sh -c "tar -czvf ${var_backupDir}/${var_backupJenkinsHomeFilename} ${var_jenkinsHomeDir}" \
    && docker start "jenkins-server" \
    && printf -- "\nData backup for ${var_jenkinsHomeDir} has been done and saved as ${var_backupJenkinsHomeFilename}\n"
  } \
  || return 1
}

init__CidServer_restore() {
  printf -- "\n[$(date) @ X] Info: init CID Server - Restore Server data\n" \
  && {
    local var_backupDir="/usr/src/0.host-share/backups"
    read -p $'Jenkins Server will be stopped for restore and then restarted, continue? (y/n) ' var_common_confirmationkey \
    && [ 'y' = "${var_common_confirmationkey}" ] \
    && docker stop "jenkins-server" \
    && docker run --rm -u root --volumes-from "jenkins-server" "${var_jenkinsDockerImage}" sh -c "rm -rf ${var_jenkinsHomeDir}/* && tar -xzvf ${var_backupDir}/$2 -C /" \
    && docker start "jenkins-server" \
    && printf -- "\nData backup has been restored\n"
  } \
  || return 1
}

main() {
  printArgs "$@"
  while true; do
    if [ "server.launch" = "$1" ]; then
      init__CidServer_launch "$@" || break
    elif [ "server.setup" = "$1" ]; then
      init__CidServer_setup "$@" || break
    elif [ "script.jenkins.setup" = "$1" ]; then
      script__Jenkins_setup "$@" || break
    elif [ "server.backup" = "$1" ]; then
      init__CidServer_backup "$@" || break
    elif [ "server.restore" = "$1" ]; then
      init__CidServer_restore "$@" || break
    else
      printf -- "\nUsage example: $0 server.launch\n"
      printf -- "\nUsage example: $0 server.setup\n"
      printf -- "\nUsage example: $0 server.backup\n"
      printf -- "\nUsage example: $0 server.restore jenkins_home_BAKYYYY-MM-DDTHH-mm-ssUTC.tar.gz\n"
      break
    fi
    printf -- "\n[$(date) @ X] Success!\n"
    return
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"
