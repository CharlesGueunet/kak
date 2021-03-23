# Plugins
# ───────

# plugin manager
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

## Buffers

plug "Delapouite/kakoune-buffers" %{
  map global user 'b' ': enter-user-mode buffers<ret>' -docstring 'buffers manipulation'
  map global buffers 'b' ': pick-buffers<ret>' -docstring 'buffer pick'
}

## Selection

# one by one manip
plug "occivink/kakoune-phantom-selection" %{
  declare-user-mode selection
  map global user 'f' ': enter-user-mode selection<ret>'                                    -docstring 'phantom selection manipulations'
  map global selection a     ": phantom-selection-add-selection<ret>"                       -docstring 'add selection'
  map global selection r     ": phantom-selection-select-all; phantom-selection-clear<ret>" -docstring 'reset selection'
  map global selection <a-f> ": phantom-selection-iterate-next<ret>"                        -docstring 'next selection'
  map global selection <a-F> ": phantom-selection-iterate-prev<ret>"                        -docstring 'prev selection'
  map global insert <a-f>    "<esc>: phantom-selection-iterate-next<ret>a"
  map global insert <a-F>    "<esc>: phantom-selection-iterate-prev<ret>a"
  set-face global PhantomSelection default,default+u
}

## Text

# surround
plug "alexherbo2/auto-pairs.kak" %{
  require-module auto-pairs
  auto-pairs-enable
}
plug "alexherbo2/word-select.kak" %{
  require-module word-select
  map global normal w ': word-select-next-word<ret>'
  map global normal <a-w> ': word-select-next-big-word<ret>'
  map global normal q ': word-select-previous-word<ret>'
  map global normal <a-q> ': word-select-previous-big-word<ret>'
}
plug "h-youhei/kakoune-surround" %{
  declare-user-mode surround
  map global normal '<c-s>' ': enter-user-mode surround<ret>'
  map global surround s ': surround<ret>'               -docstring 'surround'
  map global surround c ': change-surround<ret>'        -docstring 'change'
  map global surround d ': delete-surround<ret>'        -docstring 'delete'
  map global surround t ': select-surrounding-tag<ret>' -docstring 'select tag'
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
    # hook global WinSetOption filetype=(cmake) %{
    #     map window user 'l' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
    #     lsp-enable-window
    # }
    hook global WinSetOption filetype=(c|cpp|rust) %{
        map window user 'l' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
        lsp-enable-window
        lsp-auto-hover-enable
        lsp-auto-hover-insert-mode-enable
        set-option window lsp_hover_anchor true
        set-face window DiagnosticError default+u
        set-face window DiagnosticWarning default+u
    }
    hook global WinSetOption filetype=python %{
        lsp-enable-window
    }
    hook global WinSetOption filetype=rust %{
        set-option window lsp_server_configuration rust.clippy_preference="on"
    }
    hook global KakEnd .* lsp-exit
}

# snippets
plug "occivink/kakoune-snippets" config %{
    set-option -add global snippets_directories "%opt{plug_install_dir}/kakoune-snippet-collection/snippets"
    set-option global snippets_auto_expand false
    map global insert '<c-s>' '<a-;>: snippets-expand-trigger<ret><esc>'
    map global insert '<c-n>' '<a-;>: snippets-select-next-placeholders<ret><esc>'
    map global normal '<c-n>' ': snippets-select-next-placeholders<ret>'
    declare-user-mode snippets
    map global user 'S' ': enter-user-mode snippets<ret>' -docstring 'snippet menu'
    map global snippets 's' ': snippets-info<ret>' -docstring 'show snippets'
}
plug "andreyorst/kakoune-snippet-collection"

# plug "raiguard/one.kak" theme

