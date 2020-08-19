#!/bin/sh
init__DevExB_pull() {
  local urlexb="https://devtopia.esri.com/Beijing-R-D-Center/ExperienceBuilder.git"
  local urlexbext="https://devtopia.esri.com/Beijing-R-D-Center/ExperienceBuilder-Web-Extensions.git"
  cd "${var_cwd}" || return 1
  # # When using submodule: git submodule add "${urlexbext}" ./client/extensions
  # test -d "${var_pathexb}" || git clone --recursive "${urlexb}" || return 1
  test -d "${var_pathexb}" || git clone "${urlexb}" "${var_pathexb}" || return 1
  test -d "${var_pathexb}/client/extensions" || git clone "${urlexbext}" "${var_pathexb}/client/extensions" || return 1
  cd "${var_cwd}" && cd "${var_pathexb}/client/extensions" && git pull || return 1
  cd "${var_cwd}" && cd "${var_pathexb}" && git pull || return 1

  # ensure helpful devtool configs
  local pathexb_vscode="${var_pathexb}/.vscode"
  cd "${var_cwd}" || return 1
  mkdir -p "${pathexb_vscode}" || return 1
  test -f "${pathexb_vscode}/launch.json" || echo "${var_vscode_launch_json}" > "${pathexb_vscode}/launch.json" || return 1
}

init__DevExB_install() {
  cd "${var_cwd}" && cd "${var_pathexb}/client" && npm ci || return 1
  cd "${var_cwd}" && cd "${var_pathexb}/server" && npm ci || return 1
  cd "${var_cwd}" && cd "${var_pathexb}" && npm i || return 1
}

init__DevExB_dev() {
  gnome-terminal -- sh -c "cd '${var_pathexb}/client/' && npm start"
  gnome-terminal -- sh -c "cd '${var_pathexb}/server/' && npm start -- -d"
}

main() {
  var_pathexb="$1"
  while true; do
    if [ "code.pull" = "$2" ]; then
      set -x
      init__DevExB_pull "$@" || break
      init__DevExB_install "$@" || break
    elif [ "code.run" = "$2" ]; then
      set -x
      init__DevExB_dev "$@" || break
      printf -- "\n[$(date) @ X] Please make sure sign-in with below:\n"
      printf -- "\n[$(date) @ X] - Access URL: http://localhost:3000/page/set-portalurl\n"
      printf -- "\n[$(date) @ X] -- Portal URL: https://esridevbeijing.maps.arcgis.com\n"
      printf -- "\n[$(date) @ X] -- Client ID: (bR4L3COcJzPXifMF)\n"
      printf -- "\n[$(date) @ X] Success!\n"
    else
      printf -- "\nUsage example: $0 ./ExperienceBuilder code.pull\n"
      printf -- "\nUsage example: $0 ./ExperienceBuilder code.run\n"
      break
    fi
    return 0
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

var_pathexb=""
var_cwd="$(pwd)"
var_vscode_launch_json="$(cat << 'EOF'
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "type": "chrome",
      "request": "launch",
      "name": "Launch Chrome against localhost",
      "url": "http://localhost:8080",
      "webRoot": "${workspaceFolder}"
    },
    {
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}/client",
      "name": "jest-current-file",
      "program": "${workspaceFolder}/client/node_modules/jest/bin/jest.js",
      "args": [
        "--runInBand",
        "${fileBasenameNoExtension}"
      ]
    },
    {
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}/client",
      "name": "build experience-app-build",
      "program": "${workspaceFolder}/client/node_modules/webpack/bin/webpack.js",
      "args": [
        "--config",
        "./webpack/webpack-experience-app-build.config.js",
        "--mode=development",
        "--devtool=false",
        "--expAppId", "0",
      ]
    },
    {
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}/client",
      "name": "webpack-x",
      "program": "${workspaceFolder}/client/node_modules/webpack/bin/webpack.js",
      "args": [
        "--config",
        // "./webpack/webpack-site.config.js",
        // "./webpack/webpack-extensions.config.js",
        // "./webpack/webpack-builder.config.js",
        // "./webpack/webpack-jimu-core.config.js",
        // "./webpack/webpack-jimu-ui.config.js",
        "./webpack/webpack-experience.config.js",
        "--mode=development",
        "--devtool=false",
      ]
    },
    {
      "type": "node",
      "request": "launch",
      "cwd": "${workspaceFolder}/server",
      "name": "webpack-server",
      // "runtimeExecutable": "${workspaceFolder}/server/node_modules/nodemon/bin/nodemon.js",
      "program": "${workspaceFolder}/server/node_modules/ts-node/dist/bin.js",
      "args": [
        // "--exec",
        "./src/server.ts",
        // "--",
        "-d"
      ]
    }
  ],
}
EOF
)"

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"
