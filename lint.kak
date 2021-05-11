# Python

hook global WinSetOption filetype=python %{
  jedi-enable-autocomplete
  # set-option global lintcmd kak_pylint
  # set-option global lintcmd 'flake8'
  set-option window lintcmd "flake8 --filename='*' --format='%%(path)s:%%(row)d:%%(col)d: error: %%(text)s' --ignore=E121,E123,E126,E226,E24,E704,W503,W504,E501,E221,E127,E128,E129,F405"

declare-user-mode lint-python
  map global user 'l' ': enter-user-mode lint-python<ret>' -docstring 'enter lint mode'
  map global lint-python 'l' ': lint<ret>'                 -docstring 'update lint'
  map global lint-python 'n' ': lint-next-message<ret>'      -docstring 'next error'
  map global lint-python 'p' ': lint-previous-message<ret>'  -docstring 'previous error'
}

# Shell

hook global WinSetOption filetype=sh %{
  set-option window lintcmd "shellcheck -fgcc -Cnever"
  set-option buffer formatcmd "shfmt -i 4"
  declare-user-mode lint-shell
  map global user 'l' ': enter-user-mode lint-shell<ret>'  -docstring 'enter lint mode'
  map global lint-shell 'l' ': lint<ret>'                  -docstring 'update lint'
  map global lint-shell 'n' ': lint-next-message<ret>'     -docstring 'next error'
  map global lint-shell 'p' ': lint-previous-message<ret>' -docstring 'previous error'
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

