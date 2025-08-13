# alias definition for running things in containers, ref: https://nystudio107.com/blog/dock-life-using-docker-for-all-the-things
alias x-docker-run='docker run --rm -it --network=host -v "${PWD}":"/app" -w "/app" '
DOCKERIMG_node='docker.1ms.run/library/node:20'
alias node='x-docker-run "${DOCKERIMG_node} '
alias npm='x-docker-run "${DOCKERIMG_node}" npm '
alias npx='x-docker-run "${DOCKERIMG_node}" npx '
DOCKERIMG_deno='docker.1ms.run/denoland/deno'
alias deno='x-docker-run "${DOCKERIMG_deno}" '
alias aws='x-docker-run -v ~/.aws:/root/.aws amazon/aws-cli '
alias ffmpeg='x-docker-run jrottenberg/ffmpeg '
alias tree='f(){ x-docker-run johnfmorton/tree-cli tree "$@";  unset -f f; }; f'

alias node14='x-docker-run node:14-alpine '
alias npm14='x-docker-run node:14-alpine npm '

DOCKERIMG_openjdk='docker.1ms.run/library/openjdk:11'
alias java='x-docker-run "${DOCKERIMG_openjdk}" java '
alias javac='x-docker-run "${DOCKERIMG_openjdk}" javac '

