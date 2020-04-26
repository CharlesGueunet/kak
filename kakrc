# User preference
# ───────────────
# colorscheme solarized-light # for light terminal
set-option global ui_options ncurses_status_on_top=true
# set-option -add global ui_options ncurses_assistant=dilbert

set-option global autoreload yes
set-option global scrolloff 3,5
set-option global tabstop 2
set-option global indentwidth 2
set-option global makecmd 'make -j8'
set-option global grepcmd 'ag --column'

# Colors
# ──────
set-face global Default default,black
set-face global LineNumbers default,black
set-face global StatusLine default,black

add-highlighter global/ number-lines -hlcursor
add-highlighter global/ show-whitespaces -tab '•' -tabpad ' ' -lf ' ' -spc ' ' -nbsp '⍽'
add-highlighter global/ show-matching
add-highlighter global/ dynregex '%reg{/}' 0:+u
add-highlighter global/ regex \b(?:FIXME|TODO|XXX)\b 0:default+rb
# add-highlighter global/ show-whitespaces -only-trailing
 
set-face global Whitespace rgb:465258,default

# Status line
# ───────────
declare-option -docstring 'name of the git executable' \
    str modeline_git_val
declare-option -docstring 'name of the git branch holding the current buffer' \
    str modeline_git_branch

hook global WinCreate .* %{
    # Done in two pass to deal with colors
    hook window NormalIdle .* %{ evaluate-commands %sh{
        repo=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --git-dir 2> /dev/null)
        if [ -n "${repo}" ]; then
            printf 'set window modeline_git_val "git:"'
        else
            printf 'set window modeline_git_val ""'
        fi
    } }
    hook window NormalIdle .* %{ evaluate-commands %sh{
        branch=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "${branch}" ]; then
            printf 'set window modeline_git_branch %%{%s}' "${branch}"
        else
            printf 'set window modeline_git_branch ""'
        fi
    } }
}
set-option global modelinefmt '{{context_info}} {{mode_info}}
on {green}%val{bufname}{default}:{cyan}%val{cursor_line}{default}:{cyan}%val{cursor_char_column}{default}
%opt{modeline_git_val}{yellow}%opt{modeline_git_branch}{default}'

# Custom mappings
# ───────────────

map global normal , <space>
map global normal <space> ,
map global normal \' \"
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
# select previous word (bash like)
map global insert <c-w> '<a-;>h<a-;><a-B>'
# open line above
map global insert <c-o> '<a-;>O'

declare-option -hidden int kak_opt_autowrap_column
set-option global kak_opt_autowrap_column 80
# format with =
map global normal = '|fmt -w $kak_opt_autowrap_column<ret>'

# comment with #
map global normal '#' :comment-line<ret>

# clear search buffer
map global user ',' ':set-register / ""<ret><c-l>' -docstring 'clear search'

# Move mode
declare-user-mode quickmove
map global user 'v' ': enter-user-mode -lock quickmove<ret>'    -docstring 'enter quickmove mode' 
map global quickmove 'k' 'k'          -docstring 'line above'
map global quickmove 'j' 'j'          -docstring 'line below'
map global quickmove 'h' 'h'          -docstring 'left char'
map global quickmove 'l' 'l'          -docstring 'right char'
map global quickmove 'K' '[p;'        -docstring 'paragraph above'
map global quickmove 'J' ']p;'        -docstring 'paragraph below'
map global quickmove 'H' 'I<esc>'     -docstring 'line begining'
map global quickmove 'L' '<a-l>;'     -docstring 'line end'
map global quickmove 'I' '[i;I<esc>'  -docstring 'indent level above'
map global quickmove 'i' ']i;I<esc>'  -docstring 'indent level below'
map global quickmove '{' '[};'        -docstring 'brace block above'
map global quickmove '}' ']};'        -docstring 'brace block below'
map global quickmove '(' '[);'        -docstring 'parenthesis block above'
map global quickmove ')' ']);'        -docstring 'parenthesis block below'
map global quickmove 'n' '<esc><tab>' -docstring 'jump next position'
map global quickmove 'p' '<esc><c-o>' -docstring 'jump previous position'

# Git
define-command git-show-blamed-commit %{
  git show %sh{git blame -L "$kak_cursor_line,$kak_cursor_line" "$kak_buffile" | awk '{print $1}'}
}
define-command git-log-lines %{
  git log -L %sh{
    anchor="${kak_selection_desc%,*}"
    anchor_line="${anchor%.*}"
    echo "$anchor_line,$kak_cursor_line:$kak_buffile"
  }
}
define-command git-toggle-blame %{
  try %{
    add-highlighter window/git-blame group
    remove-highlighter window/git-blame
    git blame
  } catch %{
    git hide-blame
  }
}
define-command git-hide-diff %{
  remove-highlighter window/git-diff
}
declare-user-mode git
map global user 'g' ':enter-user-mode git<ret>'    -docstring 'enter git mode' 
map global git 'b' ': git-toggle-blame<ret>'       -docstring 'blame (toggle)'
map global git 'l' ': git log<ret>'                -docstring 'log'
map global git 'c' ': git commit<ret>'             -docstring 'commit'
map global git 'd' ': git diff<ret>'               -docstring 'diff'
map global git 's' ': git status<ret>'             -docstring 'status'
map global git 'h' ': git show-diff<ret>'          -docstring 'show diff'
map global git 'H' ': git-hide-diff<ret>'          -docstring 'hide diff'
map global git 'w' ': git-show-blamed-commit<ret>' -docstring 'show blamed commit'
map global git 'L' ': git-log-lines<ret>'          -docstring 'log blame'
# chain commands
map global git 'n' ': git show-diff<ret>: git next-hunk<ret>' -docstring 'next hunk'
map global git 'p' ': git show-diff<ret>: git prev-hunk<ret>' -docstring 'prev hunk'

# Enable <tab>/<s-tab> for insert completion selection
# ──────────────────────────────────────────────────────

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# Filetype specific
# ─────────────────

# C / CPP: CMake
# TODO: separate plugin
hook global WinSetOption filetype=(c|cpp|cmake) %{
  declare-option -docstring 'build folder' str cmake_build_folder
  declare-option -docstring 'nb core to build' int cmake_nb_cores

  set-option buffer cmake_build_folder "build"
  set-option global cmake_nb_cores 6

  define-command -override cmake-set-nb_cores -params 1 %{
    set-option global cmake_nb_cores %arg{1}
  }
  define-command -override -hidden -params 2 cmake-fifo %{ evaluate-commands %sh{
      cmake_opt=$1
      cmake_type=$2
      fifo_file=$(mktemp -d "${TMPDIR:-/tmp}"/kak-build.XXXXXXXX)/fifo
      mkfifo ${fifo_file}
      ( cmake ${cmake_opt} > $fifo_file 2>&1 && notify-send "${cmake_type} sucess" || notify-send -u critical "${cmake_type} failed" & ) > /dev/null 2>&1 < /dev/null
      printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
                edit! -fifo ${fifo_file} *CMake* -scroll
                hook -always -once buffer BufCloseFifo .* %{ nop %sh{ rm -r $(dirname ${fifo_file}) } }
            }"
    }
  }
  define-command -override cmake-build -docstring "Verbose build" %{
      cmake-fifo "--build %opt{cmake_build_folder} -- -j %opt{cmake_nb_cores}" "Build"
  }
  define-command -override cmake-install -docstring "Verbose install" %{
      cmake-fifo "--build %opt{cmake_build_folder} --target install -- -j %opt{cmake_nb_cores}" "Install"
  }
  declare-user-mode cmake
  map global user   'c' ': enter-user-mode cmake<ret>'         -docstring 'enter CMake mode'
  map global cmake  'c' ': terminal ccmake -S . -B build<ret>' -docstring 'configure CMake'
  map global cmake  'b' ': eval -draft cmake-build<ret>'       -docstring 'silent build'
  map global cmake  'B' ': cmake-build<ret>'                   -docstring 'verbose build'
  map global cmake  'i' ': eval -draft cmake-install<ret>'     -docstring 'silent install'
  map global cmake  'I' ': cmake-install<ret>'                 -docstring 'verbose install'
  map global cmake  's' ': buffer *CMake*<ret>'                -docstring 'show CMake buffer'
  map global cmake  'p' ': cmake-set-nb_cores '                -docstring 'set number of cores to use'
}

hook global WinSetOption filetype=(cpp) %{
  map global user -docstring 'alternate header/source' 'a' ':cpp-alternative-file<ret>'
}
hook global WinSetOption filetype=(c) %{
  map global user -docstring 'alternate header/source' 'a' ':c-alternative-file<ret>'
}

# Python
hook global WinSetOption filetype=python %{
  jedi-enable-autocomplete
  set-option global lintcmd kak_pylint
  # set-option global lintcmd 'flake8'
  lint-enable

  declare-user-mode lint-python
  map global user 'l' ': enter-user-mode lint-python<ret>' -docstring 'enter lint mode'
  map global lint-python 'l' ': lint<ret>'                 -docstring 'update lint'
  map global lint-python 'n' ': lint-next-error<ret>'      -docstring 'next error'
  map global lint-python 'p' ': lint-previous-error<ret>'  -docstring 'previous error'
}

# XML
map -docstring 'XML tag objet' global object t %{c<lt>([\w.]+)\b[^>]*?(?<lt>!/)>,<lt>/([\w.]+)\b[^>]*?(?<lt>!/)><ret>}
hook global BufCreate .vt.* %{ # VTK file types are XML
  set-option buffer filetype xml
}

# Highlight the word under the cursor
# ───────────────────────────────────

declare-option -hidden regex curword
set-face global CurWord default,rgb:4a4a4a
# set-face global CurWord default,rgb:ffcaca # for light terminal

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

# System clipboard handling
# ─────────────────────────

evaluate-commands %sh{
    case $(uname) in
        Linux) copy="xclip -i"; paste="xclip -o" ;;
        Darwin)  copy="pbcopy"; paste="pbpaste" ;;
    esac

    printf "map global user -docstring 'paste from clipboard' p '!%s<ret>'\n" "$paste"
    printf "map global user -docstring 'yank to clipboard' y '<a-|>%s<ret>:echo -markup %%{{Information}copied selection to X11 clipboard}<ret>'\n" "$copy"
}

# Plugins
# ───────

# plugin manager
source "%val{config}/plugins/plug.kak/rc/plug.kak"
plug "andreyorst/plug.kak" noload

## External commands

# fzf
plug "andreyorst/fzf.kak" config %{
  map global user  'f' ': fzf-mode<ret>' -docstring 'fuzzy navigation'
} defer "fzf" %{
  set-option global fzf_preview_width '65%'
  set-option global fzf_project_use_tilda true
  evaluate-commands %sh{
    if [ -n "$(command -v fd)" ]; then
      echo "set-option global fzf_file_command %{fd . --no-ignore --type f --follow --hidden --exclude .git --exclude .svn}"
    else
      echo "set-option global fzf_file_command %{find . \( -path '*/.svn*' -o -path '*/.git*' \) -prune -o -type f -follow -print}"
    fi
    [ -n "$(command -v bat)" ] && echo "set-option global fzf_highlight_command bat"
    [ -n "${kak_opt_grepcmd}" ] && echo "set-option global fzf_sk_grep_command %{${kak_opt_grepcmd}}"
  }
}

## Buffers

plug "Delapouite/kakoune-buffers" %{
  map global user 'b' ': enter-buffers-mode<ret>' -docstring 'buffers manipulation'
}

## Selection

# special split
plug "alexherbo2/split-object.kak" %{
  map global normal <a-I> ': enter-user-mode split-object<ret>'
}
plug "occivink/kakoune-phantom-selection" %{
  declare-user-mode selection
  map global user 's' ': enter-user-mode selection<ret>'                                    -docstring 'selection manipulations'
  map global selection a     ": phantom-selection-add-selection<ret>"                       -docstring 'add selection'
  map global selection r     ": phantom-selection-select-all; phantom-selection-clear<ret>" -docstring 'reset selection'
  map global selection <a-f> ": phantom-selection-iterate-next<ret>"                        -docstring 'next selection'
  map global selection <a-F> ": phantom-selection-iterate-prev<ret>"                        -docstring 'prev selection'
  map global insert <a-f>    "<esc>: phantom-selection-iterate-next<ret>i"
  map global insert <a-F>    "<esc>: phantom-selection-iterate-prev<ret>i"
}

## Text

# surround
plug "alexherbo2/auto-pairs.kak"
plug "h-youhei/kakoune-surround" %{
  declare-user-mode surround
  map global normal '<c-s>' ': enter-user-mode surround<ret>'
  map global surround s ': surround<ret>'               -docstring 'surround'
  map global surround c ': change-surround<ret>'        -docstring 'change'
  map global surround d ': delete-surround<ret>'        -docstring 'delete'
  map global surround t ': select-surrounding-tag<ret>' -docstring 'select tag'
}

# digits vim like
plug "https://gitlab.com/Screwtapello/kakoune-inc-dec" %{
  map global normal <c-a> ': inc-dec-modify-numbers + %val{count}<ret>'
  map global normal <c-x> ': inc-dec-modify-numbers - %val{count}<ret>'
}

# navigation
plug "danr/kakoune-easymotion" %{
  map global user ' ' ': enter-user-mode easymotion<ret>' -docstring 'easymotion'
  map global easymotion 'b' ': easy-motion-b<ret>' -docstring 'word ←'
  map global easymotion 'B' ': easy-motion-B<ret>' -docstring 'Word ←'
  unmap global easymotion 'q'
  unmap global easymotion 'Q'
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
    # hook global WinSetOption filetype=python %{
    #   set-option global lsp_server_configuration pyls.configurationSources=["flake8"]
    # }
    hook global WinSetOption filetype=rust %{
        set-option window lsp_server_configuration rust.clippy_preference="on"
    }
    hook global KakEnd .* lsp-exit
}
#snippets
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
