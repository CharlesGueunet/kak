# Options
# ───────

set-option global autoreload yes
set-option global scrolloff 3,5
set-option global tabstop 2
set-option global indentwidth 2
set-option global grepcmd 'ag --hidden --ignore .ccls-cache --ignore build*'

# Session
# ───────

evaluate-commands %sh{
  kks init
}

# Config
# ──────

source "%val{config}/style.kak"

source "%val{config}/status.kak"

source "%val{config}/mapping.kak"

source "%val{config}/quickmove.kak"

source "%val{config}/next.kak"

source "%val{config}/git.kak"

source "%val{config}/cmake.kak"

source "%val{config}/lint.kak"

# all plugins are here
source "%val{config}/plug.kak"

try %{
  source "%val{config}/local.kak"
}
