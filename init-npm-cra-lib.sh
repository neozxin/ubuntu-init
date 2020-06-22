#!/bin/sh

main() {
  while true; do
    printf -- "\n================ TypeScript NPM App Library Init Scripts: 2.0.200326 ================\n"
    printf -- "\n[$(date) @ X] Start running scripts...\n"
    [ -z "$1" ] && {
      printf -- "\nUsage example: $0 my-npm-project-name\n"
      break
    }
    # cd $(cd `dirname $0` && pwd)
    set -x

    # install prerequisites
    ## install NodeJS
    node -v 2>/dev/null || {
      printf -- "\n[$(date) @ X] 安装NodeJS应用 Install NodeJS\n"
      # # snap 安装方式或可造成本脚本运行失败
      # sudo snap install node --classic --channel=12 \
      sudo apt-get install -y curl \
      && curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash - \
      && sudo apt-get install -y nodejs \
      && node -v 2>/dev/null
    } || break

    # init project directories
    npx -p create-react-app@3.4.0 create-react-app "$1" --use-npm --template typescript || break
    cd "$1" || break

    # local npm registries
    echo "##### registry = https://registry.npm.taobao.org" > "./.npmrc" || break
    # sudo npm config set registry https://registry.npm.taobao.org \
    # && sudo npm config list \
    # || break

    # update project package.json
    # essentials
    npm install copyfiles@2.2.0 dot-json@1.2.0 rimraf@3.0.2 --save-dev || break
    # optionals
    npm install @storybook/cli@5.3.17 http-server@0.12.1 husky@4.2.3 \
      jest-image-snapshot@3.0.1 prettier@2.0.2 pretty-quick@2.0.1 \
      puppeteer@2.1.1 react-app-rewired@2.1.5 start-server-and-test@1.10.11 \
      --save-dev || break
    # devlibs
    npm install node-sass@^4.13.1 --save || break
    npm install body-parser@1.19.0 cors@2.8.5 express@4.17.1 express-ws@4.0.0 fs-extra@9.0.0 --save || break

    npx dot-json "./package.json" 'scripts.build' 'react-app-rewired build' || break
    npx dot-json "./package.json" 'scripts.test' 'react-app-rewired test --ci=true --env=jsdom --coverage --watchAll=false --testMatch=**\/*\\.{spec,test}\\.{js,jsx,ts,tsx}' || break
    npx dot-json "./package.json" 'scripts.test:aat' "npm run build && start-server-and-test 'http-server -c-1 -p 8881' 8881 'react-app-rewired test --ci=true --forceExit --watchAll=false --testMatch=**\/*\\.aa-test\\.{js,jsx,ts,tsx}'" || break
    npx dot-json "./package.json" 'scripts.lib:build' 'rimraf ./build/_build-lib && tsc -p ./src/lib-repo/tsconfig.json && copyfiles -u 2 ./src/lib-repo/**/*.*css ./src/lib-repo/assets/*.* ./src/lib-repo/package.json ./src/lib-repo/*.md ./src/lib-repo/cli.js ./build/_build-lib' || break
    npx dot-json "./package.json" 'scripts.lib:publishnpm' 'npm run lib:build && npm publish ./build/_build-lib' || break
    npx dot-json "./package.json" 'husky.hooks.pre-commit' 'pretty-quick --staged' || break

    # ensure helpful devtool configs
    mkdir -p "./.vscode" || break
    echo "${var_vscode_launch_json}" > "./.vscode/launch.json" || break
    echo "${var_root_prettierrc_js}" > "./.prettierrc.js" || break

    echo "${var_root_config_overrides_js}" > "./config-overrides.js" || break
    echo "${var_root_jenkinsfile}" > "./Jenkinsfile" || break
    echo "${var_root_dockerfile_node_ci}" > "./Dockerfile_neozxin@node12-ci" || break

    mkdir -p "./src/__tests__" || break
    echo "${var_test_main_aa_test_ts}" > "./src/__tests__/main.aa-test.js" || break

    mkdir -p "./src/lib-repo/z-demo-com1" || break

    # npm init --yes
    echo "${var_lib_package_json}" > "./src/lib-repo/package.json" || break

    # npx tsc --init
    echo "${var_lib_tsconfig_json}" > "./src/lib-repo/tsconfig.json" || break

    echo "${var_lib_cli_ts}" > "./src/lib-repo/cli.js" || break

    echo "README" > "./src/lib-repo/README.md" || break

    # sample lib code
    echo "${var_lib_main_ts}" > "./src/lib-repo/main.ts" || break
    echo "${var_lib_z_demo_com1_ts}" > "./src/lib-repo/z-demo-com1/z-demo-com1.jsx" || break

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

var_vscode_launch_json="$(cat << 'EOF'
{
  "version": "0.2.0",
  "configurations": [
    // Ref: https://create-react-app.dev/docs/setting-up-your-editor#visual-studio-code
    {
      "name": "Chrome",
      "type": "chrome",
      "request": "launch",
      "url": "http://localhost:3000",
      "webRoot": "${workspaceFolder}/src",
      "sourceMapPathOverrides": {
        "webpack:///src/*": "${webRoot}/*"
      }
    },
    // Ref: https://create-react-app.dev/docs/debugging-tests#debugging-tests-in-visual-studio-code
    {
      "name": "Debug CRA Test - Current File Only",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "${workspaceRoot}/node_modules/.bin/react-app-rewired",
      "args": [
        "test",
        // "--runInBand",
        "--no-cache",
        // "--watchAll=false",
        "${fileBasenameNoExtension}"
      ],
      "cwd": "${workspaceRoot}",
      "protocol": "inspector",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "env": {
        "CI": "true"
      },
      "disableOptimisticBPs": true
    },
    // Ref: https://code.visualstudio.com/docs/nodejs/nodejs-debugging
    {
      "name": "Debug NodeJS file",
      "type": "node",
      "request": "launch",
      "program": "${file}",
      "args": [
        "testarg"
      ],
      "cwd": "${workspaceRoot}",
      "protocol": "inspector",
      "console": "integratedTerminal",
      "internalConsoleOptions": "neverOpen",
      "env": {
        "CI": "true"
      },
      "disableOptimisticBPs": true
    }
  ]
}
EOF
)"

var_root_prettierrc_js="$(cat << 'EOF'
// Ref: https://prettier.io/docs/en/options.html
module.exports = {
  singleQuote: true,
  // trailingComma: "es5",
  // arrowParens: "always",
};
EOF
)"

var_root_config_overrides_js="$(cat << 'EOF'
module.exports = function override(config, env) {
  // used by react-app-rewired, do stuff with the webpack config...
  console.log('[xxxxx] sys env: ', env);
  console.log('[xxxxx] sys config: ', config);
  return config;
}
EOF
)"

var_root_jenkinsfile="$(cat << 'EOF'
// Pipeline workflow ref: https://jenkins.io/doc/book/resources/pipeline/realworld-pipeline-flow.png
node {
  def var_main_artifact = "${env.BUILD_TAG}_build.tar.gz"
  stage('Welcome') {
    echo "[xxxxx] Running Job: ${JOB_NAME}"
    echo " - Build Number: ${env.BUILD_NUMBER}"
    echo " - Workspace(PWD): ${env.WORKSPACE}"
    echo " - Jenkins URL: ${env.JENKINS_URL}"
  }
  try {
    stage('代码获取 SCM Checkout') {
      // checkout scm
      checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/neozxin/cra-applib0.git']]])
    }
    stage('安装依赖 Collect Dependencies') {
      // .withRun('-p 8081:8081 -p 8080:8080') { c ->
      docker.image('node:12.16.1').inside('--net=host') {
        sh "npm install"
      }
    }
    stage('构建内容 Build') {
      parallel 'Build Package': {
        docker.image('node:12.16.1').inside('--net=host') {
          sh "npm run build && tar -czf - ./build | cat > './${var_main_artifact}'"
          // sh "ssh '${ENV_BUILD_SERVER_USER}@${ENV_BUILD_SERVER_HOST}' docker run -i --rm --net=host -w '${WORKSPACE}/.' --volumes-from 'jenkins-server' 'node:12.16.1' sh -c -- '\"'npm install '&''&' npm run build'\"'"
        }
      }, 'Unit Test': {
        docker.image('node:12.16.1').inside('--net=host') {
          sh "npm run test"
        }
      }
    }
    stage('集成测试 Test') {
      // Ref: https://github.com/puppeteer/puppeteer/blob/master/docs/troubleshooting.md#running-puppeteer-in-docker
      // def testImage = docker.build("neozxin/node12-ci", "-f 'Dockerfile_neozxin@node12-ci' './.'")
      docker.image('neozxin/node12-ci').inside {
        sh "npm run test:aat"
      }
    }
    stage('产出分发 Deliver') {
      docker.image('node:12.16.1').inside('--net=host') {
        echo "For now, there is no any"
      }
    }
  }
  catch (exc) {
    echo '[xxxxx] Something Failed'
    sh 'false'
  }
  finally {
    echo "[xxxxx] Artifacts will be stored at '${WORKSPACE}/../../jobs/${JOB_NAME}/builds/${env.BUILD_NUMBER}/'"
    archiveArtifacts artifacts: "**/${var_main_artifact}", fingerprint: true
    sh "rm -rf './${var_main_artifact}'"
    // junit "coverage/*.xml"
  }
}
EOF
)"

var_root_dockerfile_node_ci="$(cat << 'EOF'
FROM node:12.16.1

RUN apt-get update && \
    apt-get -y install xvfb gconf-service libasound2 libatk1.0-0 libc6 libcairo2 libcups2 \
      libdbus-1-3 libexpat1 libfontconfig1 libgcc1 libgconf-2-4 libgdk-pixbuf2.0-0 libglib2.0-0 \
      libgtk-3-0 libnspr4 libpango-1.0-0 libpangocairo-1.0-0 libstdc++6 libx11-6 libx11-xcb1 libxcb1 \
      libxcomposite1 libxcursor1 libxdamage1 libxext6 libxfixes3 libxi6 libxrandr2 libxrender1 libxss1 \
      libxtst6 ca-certificates fonts-liberation libappindicator1 libnss3 lsb-release xdg-utils wget && \
    rm -rf /var/lib/apt/lists/*

# Add user so we don't need --no-sandbox.
RUN groupadd -r pptruser && useradd -r -g pptruser -G audio,video pptruser \
    && mkdir -p /home/pptruser/Downloads \
    && chown -R pptruser:pptruser /home/pptruser

# Run everything after as non-privileged user.
USER pptruser
EOF
)"

var_test_main_aa_test_ts="$(cat << 'EOF'
import puppeteer from 'puppeteer';
import { toMatchImageSnapshot } from 'jest-image-snapshot';

expect.extend({ toMatchImageSnapshot });

let browser, page;

beforeAll(async () => {
  browser = await puppeteer.launch();
  page = await browser.newPage();
  await page.setViewport({ width: 960, height: 1080 });
  return page;
});

describe('For image regression:', () => {
  it('default view', async () => {
    await page.goto(
      'http://localhost:8881' /*, { waitUntil: 'networkidle2' }*/
    );
    // console.log('[xxxxx] page content:', await page.content());
    const image = await page.screenshot(/*{ path: 'test.png' }*/);
    // await page.pdf({ path: 'test.pdf', format: 'A4' });
    // expect(image).toMatchImageSnapshot(/*{ failureThreshold: '5' }*/);
    // await page.click('a.App-link');
  });
});
EOF
)"

var_lib_package_json__name="neozxin--npm-module"
var_lib_package_json="$(cat << EOF
{
  "name": "${var_lib_package_json__name}",
  "version": "1.0.0",
  "description": "",
  "main": "./main.js",
  "bin": "./cli.js",
  "author": "neozxin",
  "license": "ISC"
}
EOF
)"

var_lib_cli_ts="$(cat << 'EOF'
#!/usr/bin/env node
console.log('neozxin welcomes you, your arguments: ', process.argv);
EOF
)"

var_lib_tsconfig_json="$(cat << 'EOF'
{
  "compilerOptions": {
    "outDir": "../../build/_build-lib",
    "module": "commonjs",
    "target": "es5",
    "lib": ["es2015", "dom"],
    "sourceMap": true,
    "declaration": true,
    "jsx": "react",
    "rootDirs": ["src", "stories"],
    "noImplicitAny": false,
    "allowJs": true,
    "allowSyntheticDefaultImports": true,
    "experimentalDecorators": true,
    "emitDecoratorMetadata": true,
    "esModuleInterop": true
  },
  "files": ["./main.ts"]
}
EOF
)"

var_lib_main_ts="$(cat << 'EOF'
export { default as ZDemoCom1 } from './z-demo-com1/z-demo-com1';
EOF
)"

var_lib_z_demo_com1_ts="$(cat << 'EOF'
import React from 'react';
//import './z-demo-com1.scss';

// utils
const componentUtils = {
  toPascalCase(text) {
    function clearAndUpper(text) {
      return text.replace(/-/, '').toUpperCase();
    }
    return text.replace(/(^\w|-\w)/g, clearAndUpper);
  },
  getFinalProps: ({ defaultPropCreators = {}, props = {} } = {}) => {
    return {
      ...Object.entries(defaultPropCreators)
        .filter((entry) => typeof props[entry[0]] === 'undefined')
        .reduce(
          (defaultProps, entry) => ({
            ...defaultProps,
            [entry[0]]: entry[1](),
          }),
          {}
        ),
      ...props,
    };
  },
  createFunctionComponent: (optMap = {}, defaultPropCreators = {}) => {
    const optMapClassName =
      typeof optMap === 'string' ? optMap : optMap.className;
    function fn(props = {}) {
      const finalProps = componentUtils.getFinalProps({
        defaultPropCreators,
        props,
      });
      const getUtils = () => {
        const { typeid = `defaultType`, className = `` } = finalProps;
        const elProps = {
          className: `${optMapClassName || '--base-com'} ${className}`,
          'data-typeid': typeid,
        };
        return { elProps, typeid };
      };
      return finalProps.render(finalProps, getUtils);
    }
    return Object.assign(fn, {
      __comName: componentUtils.toPascalCase(optMapClassName),
    });
  },
};

// configs
const demoConfigs = {
  getZDemoCom1Config: () => {
    return {
      displayName: 'non default display name'
    }
  }
}

// ZDemoCom1
const ZDemoCom1 = componentUtils.createFunctionComponent({
  config: () => demoConfigs.getZDemoCom1Config(),
  render: () => (props) => {
    const { className = '', data, config } = props;
    const elProps = { className: `z-demo-com1 ${className}` };
    if (!data || !config) return <div {...elProps}>Invalid Props</div>;
    return (
      <div {...elProps} title={JSON.stringify(config)}>
        {typeof props.children === 'function' ? props.children(props) : props.children}
      </div>
    );
  }
});

export const myZDemoCom1 = <ZDemoCom1 data={'testData'}>{(p) => <div>final props: {JSON.stringify(p)}</div>}</ZDemoCom1>;
export default ZDemoCom1;
EOF
)"

[ -n "${____verbose}" ] && set -x
main "$@"
__retVal=$? && return ${__retVal} 2>/dev/null || exit "${__retVal}"
