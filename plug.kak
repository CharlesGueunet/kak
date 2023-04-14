# Plugins
# ───────

# plugin manager
evaluate-commands %sh{
  plugins="$kak_config/plugins"
  mkdir -p "$plugins"
  [ ! -e "$plugins/plug.kak" ] && \
    git clone -q https://github.com/andreyorst/plug.kak.git "$plugins/plug.kak"
  printf "%s\n" "source '$plugins/plug.kak/rc/plug.kak'"
}
plug "andreyorst/plug.kak" noload

## Buffers

plug 'theowenyoung/kakoune-buffer-manager' config %{
    map global user 'b' ': buffer-manager<ret>' -docstring 'open buffer manager'
}
plug "natasky/kakoune-multi-file"

## Text

# handle () {} "" ...
plug "h-youhei/kakoune-surround" %{
  declare-user-mode surround
  map global normal '<c-s>' ': enter-user-mode surround<ret>'
  map global surround s ': surround<ret>'               -docstring 'surround'
  map global surround c ': change-surround<ret>'        -docstring 'change'
  map global surround d ': delete-surround<ret>'        -docstring 'delete'
  map global surround t ': select-surrounding-tag<ret>' -docstring 'select tag'
}
plug "alexherbo2/auto-pairs.kak" %{
  enable-auto-pairs
}

# completion
plug "ul/kak-lsp" do %{
  cargo build --release --locked
  cargo install --force --path .
} config %{
  define-command lsp-restart %{ lsp-stop; lsp-start }
  set-option global lsp_completion_trigger "execute-keys 'h<a-h><a-k>\S[^\h\n,=;*(){}\[\]]\z<ret>'"
  set-option global lsp_diagnostic_line_error_sign "!"
  set-option global lsp_diagnostic_line_warning_sign "•"
  hook global WinSetOption filetype=* %{
    set-option window lsp_hover_anchor false
  }
  hook global WinSetOption filetype=(cmake|sh|markdown) %{
      map window user 'l' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
      lsp-enable-window
  }
  hook global WinSetOption filetype=(c|cpp|rust) %{
    map window user 'l' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
    lsp-enable-window
    lsp-auto-hover-disable
    lsp-auto-hover-insert-mode-disable
    set-face window DiagnosticError default+u
    set-face window DiagnosticWarning default+u

    hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
    hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
    hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
    hook -once -always window WinSetOption filetype=.* %{
      remove-hooks window semantic-tokens
    }
  }
  hook global WinSetOption filetype=python %{
    map window user 'l' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
    lsp-enable-window
    lsp-auto-hover-disable
    lsp-auto-hover-insert-mode-disable

    hook window -group semantic-tokens BufReload .* lsp-semantic-tokens
    hook window -group semantic-tokens NormalIdle .* lsp-semantic-tokens
    hook window -group semantic-tokens InsertIdle .* lsp-semantic-tokens
    hook -once -always window WinSetOption filetype=.* %{
      remove-hooks window semantic-tokens
    }
  }
  hook global WinSetOption filetype=rust %{
    set-option window lsp_server_configuration rust.clippy_preference="on"
  }
  # inlay
  hook global WinSetOption filetype=(rust|python|nim|go|javascript|typescript|c|cpp) %{
    lsp-inlay-diagnostics-enable buffer
    hook buffer ModeChange pop:insert:normal %{ lsp-inlay-diagnostics-enable buffer }
    hook buffer ModeChange push:normal:insert %{ lsp-inlay-diagnostics-disable buffer }
  }
  # clean
  hook global KakEnd .* lsp-exit
}

# snippets
plug "occivink/kakoune-snippets" config %{
  set-option -add global snippets_directories "%opt{plug_install_dir}/kakoune-snippet-collection/snippets"
  set-option global snippets_auto_expand false
  map global insert '<c-s>' '<a-;>: snippets-expand-trigger<ret><esc>'
  map global insert '<c-n>' '<a-;>: snippets-select-next-placeholders<ret><esc>'
  map global normal '<c-n>' ': snippets-select-next-placeholders<ret>'
}
plug "andreyorst/kakoune-snippet-collection"

