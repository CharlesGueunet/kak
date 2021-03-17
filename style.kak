# Colors
# ──────

set-face global PrimarySelection default,rgba:30308080
set-face global SecondarySelection default,rgba:80303040
set-face global Whitespace rgba:55555520,default
set-face global Trailling default,rgba:55555520

add-highlighter global/ show-whitespaces -tab '•' -tabpad ' ' -lf '¬' -spc ' ' -nbsp '⍽'
add-highlighter global/ dynregex '%reg{/}' 0:+u
add-highlighter global/ regex \b(?:FIXME|TODO|XXX)\b 0:default+rb
add-highlighter global/ column 80 default,rgba:25252520
add-highlighter global/ column 120 default,rgba:20202020
add-highlighter global/show-trailing-whitespaces regex '\h+$' 0:Trailling

# Number line column
# ──────────────────

add-highlighter global/ number-lines -hlcursor
add-highlighter global/ wrap -word -indent -marker ↳

# Highlight the word under the cursor
# ───────────────────────────────────

declare-option -hidden regex curword
set-face global CurWord default,rgba:30303018

define-command -hidden custom-highlight-word-cursor %{
  eval -draft %{
    try %{
      exec <space><a-i>w <a-k>\A\w+\z<ret>
      set-option buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
    }
  }
}
define-command -hidden custom-highlight-word %{ %sh{
  if [ "${kak_selections_length}" = "1" ]; then
    echo "custom-highlight-word-cursor"
  else
    echo "nop"
  fi
}}
hook global RawKey .* %{
  set-option buffer curword ''
  custom-highlight-word
}
add-highlighter global/ dynregex '%opt{curword}' 0:CurWord

# Line wrap
# ──────────

declare-option -hidden int kak_opt_autowrap_column
set-option global kak_opt_autowrap_column 80
set-face global LineNumbersWrapped black,default

# Filetype
# ──────────

# ctest -> cmake
hook global BufCreate .*\.ctest %{
  set-option buffer filetype cmake
}

