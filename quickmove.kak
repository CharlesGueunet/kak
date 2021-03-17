# Move mode
# ─────────

define-command go-to-inner-ident %{
  try  %{
    execute-keys %sh{
      # get the current indent level
      printf "/^"
      printf "%s" "${kak_selection}" | head -1 | grep -Po '^\s+' | tr -d '\n'
      printf "\s<ret>)<space>w;"
    }
  }
}

declare-user-mode quickmove
map global user '<space>' ': enter-user-mode -lock quickmove<ret>'    -docstring 'enter quickmove mode' 
map global quickmove 'k' 'k'          -docstring 'line above'
map global quickmove 'j' 'j'          -docstring 'line below'
map global quickmove 'h' 'h'          -docstring 'left char'
map global quickmove 'l' 'l'          -docstring 'right char'
map global quickmove 'K' '[pk; '      -docstring 'paragraph above'
map global quickmove 'J' ']p;'        -docstring 'paragraph below'
map global quickmove '<a-k>' '10k'    -docstring '10 lines above'
map global quickmove '<a-j>' '10j'    -docstring '10 lines below'
map global quickmove '<ret>' ']p;'    -docstring 'paragraph below'
map global quickmove 'H' 'I<esc>'     -docstring 'line begining'
map global quickmove 'L' '<a-l>;'     -docstring 'line end'
map global quickmove 'I' '[i;I<esc>'  -docstring 'indent level above'
map global quickmove 'i' ']i;I<esc>'  -docstring 'indent level below'
map global quickmove '{' '<a-f>};'    -docstring 'brace block above'
map global quickmove '}' 'f};'        -docstring 'brace block below'
map global quickmove '(' '<a-f>);'    -docstring 'parenthesis block above'
map global quickmove ')' 'f);'        -docstring 'parenthesis block below'
map global quickmove 'n' '<esc><tab>' -docstring 'jump next position'
map global quickmove 'p' '<esc><c-o>' -docstring 'jump previous position'
# TODO: < > one indent level above / under
map global quickmove '<' '[i;kI<esc>'                     -docstring 'previous indent level'
map global quickmove '>' 'x: go-to-inner-ident<ret>' -docstring 'next indent level'
