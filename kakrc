# User preference
# ───────────────

set-option global ui_options ncurses_status_on_top=true
# set-option -add global ui_options ncurses_assistant=cat
 
set-option global autoreload yes
set-option global scrolloff 3,5
set-option global tabstop 2
set-option global indentwidth 2
set-option global makecmd 'make -j8'
set-option global grepcmd 'ag --column'

# Colors
# ──────
# colorscheme dracula
set-face global Default default,black
set-face global LineNumbers default,black
set-face global StatusLine default,black

add-highlighter global/number-lines number-lines
add-highlighter global/ show-matching
add-highlighter global/ dynregex '%reg{/}' 0:+u

hook global WinCreate ^[^*]+$ %{ add-highlighter window/ number-lines -hlcursor }

# Filetype specific hooks
# ───────────────────────

hook global WinSetOption filetype=python %{
  jedi-enable-autocomplete
  lint-enable
  set-option global lintcmd 'flake8'
}

map -docstring "xml tag objet" global object t %{c<lt>([\w.]+)\b[^>]*?(?<lt>!/)>,<lt>/([\w.]+)\b[^>]*?(?<lt>!/)><ret>}

# Status line
# ───────────
 
set-option global modelinefmt '{{mode_info}} {magenta}%val{client}{default} has {yellow}%sh{bs=${kak_buflist//[^:]};echo $((${#bs}+1))} buf{default} on {green}%val{bufname}{default} {{context_info}} {cyan}%val{cursor_line}{default}:{cyan}%val{cursor_char_column}{default}'

# Highlight the word under the cursor
# ───────────────────────────────────

declare-option -hidden regex curword
set-face global CurWord default,rgb:4a4a4a

hook global NormalIdle .* %{
  eval -draft %{
    try %{
      exec <space><a-i>w <a-k>\A\w+\z<ret>
      set-option buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
      set-option buffer curword ''
    }
  }
}
add-highlighter global/ dynregex '%opt{curword}' 0:CurWord

# Custom mappings
# ───────────────

map global normal , <space>
map global normal <space> ,
map global normal <ret> :
map global normal <backspace> ';'
map global normal <tab> '<a-;>'
map global normal <a-tab> '<a-:>'
# leave insert using jj
hook global InsertChar '[jj]' %{
  try %{
    execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
    execute-keys <esc>
  }
}

hook global WinSetOption filetype=(c|cpp) %{
  declare-user-mode cmake
  map global user -docstring 'enter make mode' 'c' ':enter-user-mode cmake<ret>'
  map global cmake -docstring 'configure cmake' 'c' ':terminal ccmake -S . -B build<ret>'
  map global cmake -docstring 'build with cmake' 'b' ':terminal cmake --build build -- -j 8<ret>'
  map global cmake -docstring 'install with cmake' 'i' ':terminal cmake --build build --target install -- -j 8<ret>'
}
hook global WinSetOption filetype=(cpp) %{
  map global user -docstring 'alternate header/source' 'a' ':cpp-alternative-file<ret>'
}
hook global WinSetOption filetype=(c) %{
  map global user -docstring 'alternate header/source' 'a' ':c-alternative-file<ret>'
}

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
}

# Various mappings
# ────────────────

map global normal '#' :comment-line<ret>

hook global -always BufOpenFifo '\*grep\*' %{ map -- global normal - ':grep-next-match<ret>' }
hook global -always BufOpenFifo '\*make\*' %{ map -- global normal - ':make-next-error<ret>' }

# Enable <tab>/<s-tab> for insert completion selection
# ──────────────────────────────────────────────────────

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# Helper commands
# ───────────────

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

# plugin manager
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

# buffers
plug "Delapouite/kakoune-buffers" %{
  map global user 'b' ': enter-buffers-mode<ret>' -docstring 'buffers manipulation'
}

# fzf
plug "andreyorst/fzf.kak" %{
  map global user  'f' ': fzf-mode<ret>' -docstring 'fuzzy navigation'
}

# text manipulation
plug "alexherbo2/split-object.kak" %{
  map global normal <a-I> ': enter-user-mode split-object<ret>'
}

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

# completion
plug "ul/kak-lsp" do %{
    cargo build --release --locked
    cargo install --force --path .
} config %{
    define-command lsp-restart %{ lsp-stop; lsp-start }
    set-option global lsp_completion_trigger "execute-keys 'h<a-h><a-k>\S[^\h\n,=;*(){}\[\]]\z<ret>'"
    set-option global lsp_diagnostic_line_error_sign "!"
    set-option global lsp_diagnostic_line_warning_sign "?"
    hook global WinSetOption filetype=(c|cpp|rust) %{
        map window user "l" ": enter-user-mode lsp<ret>" -docstring "LSP mode"
        lsp-enable-window
        lsp-auto-hover-enable
        lsp-auto-hover-insert-mode-enable
        set-option window lsp_hover_anchor true
        set-face window DiagnosticError default+u
        set-face window DiagnosticWarning default+u
    }
    hook global WinSetOption filetype=rust %{
        set-option window lsp_server_configuration rust.clippy_preference="on"
    }
    hook global KakEnd .* lsp-exit
}
