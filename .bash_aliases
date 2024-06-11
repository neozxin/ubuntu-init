# alias definition for running things in containers, ref: https://nystudio107.com/blog/dock-life-using-docker-for-all-the-things
alias x-docker-run='docker run --rm -it --network=host -v "${PWD}":"/app" -w "/app" '
alias node='x-docker-run node:20 '
alias npm='x-docker-run node:20 npm '
alias npx='x-docker-run node:20 npx '
