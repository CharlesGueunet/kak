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

## States

plug "https://gitlab.com/Screwtapello/kakoune-state-save" %{
  hook global KakBegin .* %{
    state-save-reg-load pipe
    state-save-reg-load arobase
    # make the q register persitent
    state-save-reg-load q
  }
  hook global KakEnd .* %{
    state-save-reg-save pipe
    state-save-reg-save arobase
    state-save-reg-save q
  }
}

## Buffers

plug "Delapouite/kakoune-buffers" %{
  map global user 'b' ': enter-user-mode buffers<ret>' -docstring 'buffers manipulation'
  map global buffers 'b' ': pick-buffers<ret>' -docstring 'buffer pick'
}

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

#selection buffer
plug https://gitlab.com/kstr0k/sel-editor.kak %{
} demand sel-editor %{
  # selection-editor
  declare-user-mode selection-editor
  map global user "s" %{: sel-editor-live-new<ret>} -docstring "selection-editor panel"
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
  # hook global WinSetOption filetype=(cmake) %{
  #     map window user 'l' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
  #     lsp-enable-window
  # }
  hook global WinSetOption filetype=(c|cpp|rust) %{
    map window user 'l' ': enter-user-mode lsp<ret>' -docstring 'LSP mode'
    lsp-enable-window
    lsp-auto-hover-enable
    lsp-auto-hover-insert-mode-enable
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
}
plug "andreyorst/kakoune-snippet-collection"

## Manually managed (given by KCr)

source "%val{config}/auto-pairs.kak"
enable-auto-pairs
