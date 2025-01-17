# Colors
# ──────

set-face global PrimarySelection default,rgba:D0D0FFF0
set-face global SecondarySelection default,rgba:A0D0A040
set-face global PrimaryCursor default,rgb:F0A0F0
set-face global SecondaryCursor default,rgb:80F090
# set-face global PrimarySelection default,rgba:30308080
# set-face global SecondarySelection default,rgba:10501040
set-face global Whitespace rgba:99999920,default

# add-highlighter global/ show-whitespaces -spc '_' -only-trailing
add-highlighter global/ show-whitespaces -tab '•' -tabpad ' ' -lf '¬' -spc ' ' -nbsp '⍽'
add-highlighter global/ dynregex '%reg{/}' 0:+u
add-highlighter global/ regex \b(?:FIXME|TODO|XXX)\b 0:default+rb
add-highlighter global/ column 80 default,rgba:CCCCCC20
add-highlighter global/ column 120 default,rgba:BBBBBB20

# Number line column
# ──────────────────

add-highlighter global/ number-lines -hlcursor
add-highlighter global/ wrap -word -indent -marker ↳

# Highlight the word under the cursor
# ───────────────────────────────────

declare-option -hidden regex curword
# set-face global CurWord default,rgba:30303018
set-face global CurWord default,rgba:C9E9C9A8

define-command -hidden custom-highlight-word-cursor %{
  eval -draft %{
    try %{
      exec ,<a-i>w<ret>
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
set-face global LineNumbersWrapped white,default

set-option global ui_options terminal_set_title=false

# Filetype
# ──────────

# ctest -> cmake
hook global BufCreate .*\.ctest %{
  set-option buffer filetype cmake
}

