# User preference
# ───────────────

set-option global makecmd 'make -j8'
set-option global grepcmd 'ag --column'
set-option global ui_options ncurses_status_on_top=true

# Colors
# ──────
# colorscheme dracula
set-face global Default default,black
set-face global LineNumbers default,black
set-face global StatusLine default,black

add-highlighter global/ show-matching
# add-highlighter global/ show-whitespaces
add-highlighter global/ dynregex '%reg{/}' 0:+u

hook global WinCreate ^[^*]+$ %{ add-highlighter window/ number-lines -hlcursor }

# Enable editor config
# ────────────────────

hook global BufOpenFile .* %{ editorconfig-load }
hook global BufNewFile .* %{ editorconfig-load }

# Filetype specific hooks
# ───────────────────────

hook global WinSetOption filetype=(c|cpp) %{
    clang-enable-autocomplete 
    clang-enable-diagnostics
    alias window lint clang-parse
    alias window lint-next-error clang-diagnostics-next
}

hook global WinSetOption filetype=python %{
    jedi-enable-autocomplete
    lint-enable
    set-option global lintcmd 'flake8'
}

map -docstring "xml tag objet" global object t %{c<lt>([\w.]+)\b[^>]*?(?<lt>!/)>,<lt>/([\w.]+)\b[^>]*?(?<lt>!/)><ret>}

# Highlight the word under the cursor
# ───────────────────────────────────

declare-option -hidden regex curword
set-face global CurWord default,rgb:4a4a4a

hook global NormalIdle .* %{
    eval -draft %{ try %{
        exec <space><a-i>w <a-k>\A\w+\z<ret>
        set-option buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
        set-option buffer curword ''
    } }
}
add-highlighter global/ dynregex '%opt{curword}' 0:CurWord

# Custom mappings
# ───────────────

map global normal = ':prompt math: %{exec "a%val{text}<lt>esc>|bc<lt>ret>"}<ret>'

# System clipboard handling
# ─────────────────────────

evaluate-commands %sh{
    case $(uname) in
        Linux) copy="xclip -i"; paste="xclip -o" ;;
        Darwin)  copy="pbcopy"; paste="pbpaste" ;;
    esac

    printf "map global user -docstring 'paste (after) from clipboard' p '!%s<ret>'\n" "$paste"
    printf "map global user -docstring 'paste (before) from clipboard' P '<a-!>%s<ret>'\n" "$paste"
    printf "map global user -docstring 'yank to clipboard' y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to X11 clipboard}<ret>'\n" "$copy"
    printf "map global user -docstring 'replace from clipboard' R '|%s<ret>'\n" "$paste"
}

# Various mappings
# ────────────────

map global normal '#' :comment-line<ret>

map global user -docstring 'next lint error' n ':lint-next-error<ret>'
map global normal <c-p> :lint<ret>

map global user -docstring 'gdb helper mode' g ':gdb-helper<ret>'
map global user -docstring 'gdb helper mode (repeat)' G ':gdb-helper-repeat<ret>'

hook global -always BufOpenFifo '\*grep\*' %{ map -- global normal - ':grep-next-match<ret>' }
hook global -always BufOpenFifo '\*make\*' %{ map -- global normal - ':make-next-error<ret>' }

# Enable <tab>/<s-tab> for insert completion selection
# ──────────────────────────────────────────────────────

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# Helper commands
# ───────────────

define-command find -params 1 -shell-script-candidates %{ ag -g '' --ignore "$kak_opt_ignored_files" } %{ edit %arg{1} }

define-command mkdir %{ nop %sh{ mkdir -p $(dirname $kak_buffile) } }

define-command ide %{
    rename-client main
    set-option global jumpclient main

    new rename-client tools
    set-option global toolsclient tools

    new rename-client docs
    set-option global docsclient docs
}

define-command delete-buffers-matching -params 1 %{
    evaluate-commands -buffer * %{
        evaluate-commands %sh{ case "$kak_buffile" in $1) echo "delete-buffer" ;; esac }
    }
}

# Plugins
# ───────

# plugin
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

# surround
plug "alexherbo2/auto-pairs.kak"
plug "h-youhei/kakoune-surround" %{
    declare-user-mode surround
    map global surround s ':surround<ret>' -docstring 'surround'
    map global surround c ':change-surround<ret>' -docstring 'change'
    map global surround d ':delete-surround<ret>' -docstring 'delete'
    map global surround t ':select-surrounding-tag<ret>' -docstring 'select tag'
    map global normal '<c-s>' ':enter-user-mode surround<ret>'
}

# move blocks
plug "alexherbo2/move-line.kak" %{
    map global normal "J" ': move-line-below<ret>'
    map global normal "K" ': move-line-above<ret>'
}
# text manipulation
plug "alexherbo2/replace-mode.kak" %{
    map global user r ': enter-replace-mode<ret>' -docstring 'Enter replace mode'
}
plug "alexherbo2/split-object.kak" %{
    map global normal <a-I> ': enter-user-mode split-object<ret>'
}

# buffers
plug "Delapouite/kakoune-buffers" %{
    map global normal <c-b> ': enter-buffers-mode<ret>' -docstring 'buffers'
}
