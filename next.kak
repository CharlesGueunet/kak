# Select next mode
# ────────────────

declare-user-mode select-next
map global user '<tab>' ': enter-user-mode select-next<ret>' -docstring 'enter select-next mode'
define-command -override -hidden select-next-param %{
  execute-keys -save-regs '/' '/[(,]<ret>l<a-i>u'
}
map global select-next "'" "f'<a-i>'"                 -docstring "select inside next single quotes"
map global select-next '"' 'f"<a-i>"'                 -docstring "select inside next double quotes"
map global select-next ')' 'f(<a-i>)'                 -docstring "select inside next parentheses"
map global select-next ']' 'f[<a-i>]'                 -docstring "select inside next brackets"
map global select-next '}' 'f{<a-i>}'                 -docstring "select inside next braces"
map global select-next '>' 'f<lt><a-i><gt>'           -docstring "select inside next angles"
map global select-next 'u' ': select-next-param<ret>' -docstring "select next argument"
map global select-next 'p' ']pj<a-i>p'                -docstring "select inside next angles"

