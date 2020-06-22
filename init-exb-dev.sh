#!/bin/sh
init__DevExB_pull() {
  local urlexb="https://devtopia.esri.com/Beijing-R-D-Center/ExperienceBuilder.git"
  local urlexbext="https://devtopia.esri.com/Beijing-R-D-Center/ExperienceBuilder-Web-Extensions.git"
  # # When using submodule: git submodule add "${urlexbext}" ./client/extensions
  # test -d ExperienceBuilder || git clone --recursive "${urlexb}" || return 1
  test -d ExperienceBuilder || git clone "${urlexb}" || return 1
  test -d ExperienceBuilder/client/extensions || git clone "${urlexbext}" "./ExperienceBuilder/client/extensions" || return 1
  cd ExperienceBuilder && git pull && cd .. || return 1
  cd ExperienceBuilder/client/extensions && git pull && cd ../../.. || return 1
}

init__DevExB_install() {
  cd ExperienceBuilder && npm ci && cd .. || return 1
  cd ExperienceBuilder/client && npm ci && cd ../.. || return 1
  cd ExperienceBuilder/server && npm ci && cd ../.. || return 1
}

init__DevExB_dev() {
  gnome-terminal -- sh -c "cd ExperienceBuilder/client/ && npm start"
  gnome-terminal -- sh -c "cd ExperienceBuilder/server/ && npm start -- -d"
}

main() {
  while true; do
    set -x
    init__DevExB_pull || break
    init__DevExB_install || break
    init__DevExB_dev || break

    printf -- "\n[$(date) @ X] Please make sure sign-in with below:\n"
    printf -- "\n[$(date) @ X] - Access URL: http://localhost:3000/page/set-portalurl\n"
    printf -- "\n[$(date) @ X] -- Portal URL: https://esridevbeijing.maps.arcgis.com\n"
    printf -- "\n[$(date) @ X] -- Client ID: (bR4L3COcJzPXifMF)\n"
    printf -- "\n[$(date) @ X] Success!\n"
    return 0
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"
