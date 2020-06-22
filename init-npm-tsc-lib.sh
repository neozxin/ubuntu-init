#!/bin/sh

main() {
  while true; do
    printf -- "\n================ TypeScript NPM Library Init Scripts: 2.0.200320 ================\n"
    [ -z "$1" ] && {
      printf -- "\nUsage example: $0 my-npm-module-name\n"
      break
    }
    cd $(cd `dirname $0` && pwd)
    set -x

    # # install prerequisites
    # ## install NodeJS
    # sudo apt-get install -y curl \
    # && curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
    # && sudo apt-get install -y nodejs \
    # || break
    # ## add better npm registries
    # sudo npm config set registry https://registry.npm.taobao.org \
    # && sudo npm config list \
    # || break


    mkdir -p "$1/src" && cd "$1" || break

    # create a entry file
    echo "${var_src_index}" > "./src/index.ts" || break

    # npm init
    echo "${var_package_json}" > "./package.json" || break

    # npx tsc --init
    echo "${var_tsconfig_json}" > "./tsconfig.json" || break

    # install dependencies
    npm install || break

    # npx -p @storybook/cli sb init --type
    npx -p @storybook/cli sb init || break

    set +x
    printf -- "\n[$(date) @ X] Ready for code development\n"
    printf -- "\n[$(date) @ X] Dev: npm run storybook\n"
    printf -- "\n[$(date) @ X] Build: npm run build\n"
    printf -- "\n[$(date) @ X] Publish to NPM: npm run publish:npm\n"
    printf -- "\n[$(date) @ X]   Make sure package.json: name & version have correct values\n"
    printf -- "\n[$(date) @ X] Success!\n"
    return
  done
  printf -- "\n[$(date) @ X] Fail...\n"
  return 1
}

var_src_index="$(cat <<EOF
export default {
  demoVar: 'my-demo-var'
}
EOF
)"

var_package_json="$(cat <<EOF
{
  "name": "neozxin--npm-module",
  "version": "1.0.0",
  "description": "",
  "main": "dist/index.js",
  "peerDependencies": {
    "react": "^16.13.1",
    "react-dom": "^16.13.1"
  },
  "dependencies": {},
  "devDependencies": {
    "@storybook/cli": "^5.3.17",
    "react": "^16.13.1",
    "react-dom": "^16.13.1",
    "typescript": "^3.8.3"
  },
  "scripts": {
    "build": "tsc",
    "publish:npm": "tsc && npm publish",
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "",
  "license": "ISC"
}
EOF
)"

var_tsconfig_json="$(cat <<EOF
{
  "compilerOptions": {
    "outDir": "./dist",
    "module": "commonjs",
    "target": "es5",
    "lib": ["es2015", "dom"],
    "sourceMap": true,
    "declaration": true,
    "jsx": "react",
    "rootDirs": ["src", "stories"],
    "noImplicitAny": false,
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "esModuleInterop": true
  },
  "files": ["src/index.ts"]
}
EOF
)"

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"
