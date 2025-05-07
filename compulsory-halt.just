# compulsory-halt.just - Halts the script when deemed necessary
not-found-halt prog justpid:
    @printf "{{RED + UNDERLINE}}not found{{NORMAL}}\n\r"
    @kill -s SIGTERM {{justpid}}
