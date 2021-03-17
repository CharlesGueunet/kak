# Custom mappings
# ───────────────

map global normal , <space>     # leader is space
map global normal <space> ,     # back to one selection
map global normal \' \"         # quick register mode
map global normal <ret> :       # quick command mode
map global normal <tab> '<a-;>' # switch side
map global normal <%> '<c-s>%'  # Save position before %

# invert q & b
map global normal q b
map global normal Q B
map global normal <a-q> <a-b>
map global normal <a-Q> <a-B>
map global normal b q
map global normal B Q

# comment with #
map global normal '#' :comment-line<ret>

# format with =
map global normal = '|fmt -w $kak_opt_autowrap_column<ret>'

# clear search buffer
map global user ',' ': set-register / ""<ret><c-l>: execute-keys "; "<ret>' -docstring 'clear search'

# case insensitive search
map global user '/' '/(?i)' -docstring "case insensitive search"

# esc with jj
hook global InsertChar '[jj]' %{
  try %{
    execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
    execute-keys <esc>
  }
}

# tab switch completion
hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# split window
define-command split %{
  new eval buffer %val{bufname} ';'
}
map global normal <c-r> ": split<ret>"

# open term
map global normal <c-t> ": connect-terminal<ret>"

# fuzzy
declare-user-mode fuzzy
map global normal <c-p> %{:enter-user-mode fuzzy<ret>} -docstring "fzf commands"
map global fuzzy b ": > kcr-fzf-buffers<ret>"          -docstring "buffers"
map global fuzzy f ": > kcr-fzf-files<ret>"            -docstring "files"
map global fuzzy g ": > kcr-fzf-grep<ret>"             -docstring "grep"

# alt + direction (insert mode)
map global insert <a-h> '<a-;><a-h>'
map global insert <a-j> '<a-;>o'
map global insert <a-k> '<a-;>O'
map global insert <a-l> '<a-;><a-l>'

# restore last selection
hook -group backup-selections global NormalIdle .* %{
  set-register b %reg{z}
  execute-keys -draft '"zZ'
}
map -docstring 'Restore selections from the [b]ackup register' global user z '"bz'

# find file
define-command find -params 1 -shell-script-candidates %{ find . -type f } %{ edit %arg{1} }

# Safe save
define-command -params 0..1 secure_write %{ evaluate-commands %sh{
  if [ -z ${1+x} ]; then
    # no param given: usual write
    echo "write"
  else
    bufname=$1
    if [ -e "${bufname}" ] && [ "${bufname}" != "${current_bufname}" ]; then
      # file already exists and is not the current one
      echo "echo 'Use w! to override existing file'"
    else
      echo "write ${bufname}"
    fi
  fi
}}
unalias global w write
alias global w secure_write

# Clipboard
map global user 'P' '!xsel --output --clipboard <ret>'     -docstring 'paste from clipboard'
map global user 'p' '<a-!>xsel --output --clipboard <ret>' -docstring 'paste from clipboard (after)'
hook global RegisterModified '"' %{ nop %sh{
  printf %s "$kak_main_reg_dquote" | xsel --input --clipboard
}}

# Custom object selections
# ─────────────────────────

# select previous word (bash like)
# useful for snippets
map global insert <c-w> '<a-;>h<a-;><a-B>'

# x extend selection below, X above
def -params 1 extend-line-down %{
  exec "<a-:>%arg{1}X"
}
def -params 1 extend-line-up %{
  exec "<a-:><a-;>%arg{1}K<a-;>"
  try %{
    exec -draft ';<a-K>\n<ret>'
    exec X
  }
  exec '<a-;><a-X>'
}
map global normal x ': extend-line-down %val{count}<ret>'
map global normal X ': extend-line-up %val{count}<ret>'

# Current indented paragraph object
define-command -hidden custom-indented-paragraph %{
  execute-keys -draft -save-regs '' '<a-i>pZ'
  execute-keys '<a-i>i<a-z>i'
}
map -docstring 'Indented paragraph' global object I '<esc>: custom-indented-paragraph<ret>'

# XML tag
map -docstring 'XML tag objet' global object t %{c<lt>([\w.]+)\b[^>]*?(?<lt>!/)>,<lt>/([\w.]+)\b[^>]*?(?<lt>!/)><ret>}
hook global BufCreate .*\.vt.* %{ # VTK file types are XML
  set-option buffer filetype xml
}

# Filetype specific
# ─────────────────

# C / CPP: CMake build system

# ,, -> <<
hook global WinSetOption filetype=(c|cpp) %{
  hook buffer InsertChar '[,,]' %{
    try %{
      execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
      execute-keys <<
    }
  }
}

# ;; -> add ; at the end of the declaration
hook global WinSetOption filetype=(c|cpp) %{
  hook buffer InsertChar '[;;]' %{
    try %{
      execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
      execute-keys -draft "<esc><a-a>(<c-l>A;"
    }
  }
}

# header / source
hook global WinSetOption filetype=(cpp) %{
  map global user -docstring 'alternate header/source' 'a' ':cpp-alternative-file<ret>'
}
hook global WinSetOption filetype=(c) %{
  map global user -docstring 'alternate header/source' 'a' ':c-alternative-file<ret>'
}

