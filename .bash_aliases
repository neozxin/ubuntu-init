# alias definition for running things in containers, ref: https://nystudio107.com/blog/dock-life-using-docker-for-all-the-things
alias x-docker-run='docker run --rm -it --network=host -v "${PWD}":"/app" -w "/app" '
alias node='x-docker-run node:20 '
alias npm='x-docker-run node:20 npm '
alias npx='x-docker-run node:20 npx '
alias deno='x-docker-run denoland/deno '
alias aws='x-docker-run -v ~/.aws:/root/.aws amazon/aws-cli '
alias ffmpeg='x-docker-run jrottenberg/ffmpeg '
alias tree='f(){ x-docker-run johnfmorton/tree-cli tree "$@";  unset -f f; }; f'

alias node14='x-docker-run node:14-alpine '
alias npm14='x-docker-run node:14-alpine npm '
