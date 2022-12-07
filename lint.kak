# C

hook global WinSetOption filetype=c %{
    set-option window lintcmd "cppcheck --language=c --enable=warning,style,information --template='{file}:{line}:{column}: {severity}: {message}' --suppress='*:*.h' 2>&1"
    set-option window formatcmd "clang-format"
}

# C++

hook global WinSetOption filetype=cpp %{
    set-option window lintcmd "cppcheck --language=c++ --enable=warning,style,information --template='{file}:{line}:{column}: {severity}: {message}' --suppress='*:*.h' --suppress='*:*.hh' 2>&1"
    set-option window formatcmd "clang-format"
}

# JSON

hook global WinSetOption filetype=json %{
    set-option window lintcmd %{ run() { cat -- "$1" | jq 2>&1 | awk -v filename="$1" '/ at line [0-9]+, column [0-9]+$/ { line=$(NF - 2); column=$NF; sub(/ at line [0-9]+, column [0-9]+$/, ""); printf "%s:%d:%d: error: %s", filename, line, column, $0; }'; } && run }
    set-option window formatcmd "jq --indent 2"
}

# Python

hook global WinSetOption filetype=python %{
  jedi-enable-autocomplete
  set-option buffer formatcmd "black -"
  set-option window lintcmd "flake8 --filename='*' --format='%%(path)s:%%(row)d:%%(col)d: error: %%(text)s' --ignore=E121,E123,E126,E226,E24,E704,W503,W504,E501,E221,E127,E128,E129,F405"
  set buffer indentwidth 4
}

# Shell

hook global WinSetOption filetype=sh %{
  set-option window lintcmd "shellcheck -x -f gcc -Cnever -a"
  set-option buffer formatcmd "shfmt -i 4"
  # declare-user-mode lint-shell
  # map global user 'l' ': enter-user-mode lint-shell<ret>'  -docstring 'enter lint mode'
  # map global lint-shell 'l' ': lint<ret>'                  -docstring 'update lint'
  # map global lint-shell 'n' ': lint-next-message<ret>'     -docstring 'next error'
  # map global lint-shell 'p' ': lint-previous-message<ret>' -docstring 'previous error'
}

# Txt, md

hook global WinSetOption filetype=(asciidoc|fountain|markdown|plain) %{
  set-option window lintcmd "proselint"
  declare-user-mode lint-txt
  map global user 'l' ': enter-user-mode lint-txt<ret>'  -docstring 'enter lint mode'
  map global lint-txt 'l' ': lint<ret>'                  -docstring 'update lint'
  map global lint-txt 'n' ': lint-next-message<ret>'     -docstring 'next error'
  map global lint-txt 'p' ': lint-previous-message<ret>' -docstring 'previous error'
}

