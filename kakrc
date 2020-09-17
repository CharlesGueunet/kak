# User preference
# ───────────────

set-option global ui_options ncurses_status_on_top=true
set-option global autoreload yes
set-option global scrolloff 3,5
set-option global tabstop 2
set-option global indentwidth 2

# Colors
# ──────

set-face global Default default,black
set-face global StatusLine default,black
set-face global LineNumbers default,black
set-face global BufferPadding default,black
set-face global PrimarySelection default,rgba:30308080
set-face global SecondarySelection default,rgba:80303040
set-face global Whitespace rgba:55555520,default

# add-highlighter global/ show-whitespaces -only-trailing
add-highlighter global/ show-whitespaces -tab '•' -tabpad ' ' -lf '¬' -spc ' ' -nbsp '⍽'
add-highlighter global/ dynregex '%reg{/}' 0:+u
add-highlighter global/ regex \b(?:FIXME|TODO|XXX)\b 0:default+rb
add-highlighter global/ column 80 default,rgb:171717
add-highlighter global/ column 120 default,rgb:191919

# Status line
# ───────────

declare-option str modeline_git_val    ''
declare-option str modeline_git_branch ''

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
# left to right
set-option global modelinefmt ''
set-option -add global modelinefmt '{{context_info}}'
set-option -add global modelinefmt ' {{mode_info}}'
set-option -add global modelinefmt ' on {green}%val{bufname}{default}:{cyan}%val{cursor_line}{default}:{cyan}%val{cursor_char_column}{default}'
set-option -add global modelinefmt ' %opt{modeline_git_val}{yellow}%opt{modeline_git_branch}{default}'

# Number line column
# ──────────────────

add-highlighter global/ number-lines -hlcursor

# Highlight the word under the cursor
# ───────────────────────────────────

declare-option -hidden regex curword
set-face global CurWord default,rgba:40404050

define-command -hidden custom-highlight-word-cursor %{
  eval -draft %{
    try %{
      exec <space><a-i>w <a-k>\A\w+\z<ret>
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

# Custom mappings
# ───────────────

map global normal , <space>
map global normal <space> ,
map global normal \' \"
map global normal <ret> :
map global normal <backspace> ';'
map global normal <tab> '<a-;>'
map global normal <a-tab> '<a-:>'

# invert q & b

map global normal q b
map global normal Q B
map global normal <a-q> <a-b>
map global normal <a-Q> <a-B>

map global normal b q
map global normal B Q

# Current indented paragraph object
define-command -hidden custom-indented-paragraph %{
  execute-keys -draft -save-regs '' '<a-i>pZ'
  execute-keys '<a-i>i<a-z>i'
}
map -docstring 'Indented paragraph' global object I '<esc>: custom-indented-paragraph<ret>'

# x extend selection below, X above
def -params 1 extend-line-down %{
  exec "<a-:>%arg{1}X"
}
def -params 1 extend-line-up %{
  exec "<a-:><a-;>%arg{1}K<a-;>"
  try %{
    exec -draft ';<a-K>\n<ret>'
    exec X
  }
  exec '<a-;><a-X>'
}
map global normal x ': extend-line-down %val{count}<ret>'
map global normal X ': extend-line-up %val{count}<ret>'

# esc with jj
hook global InsertChar '[jj]' %{
  try %{
    execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
    execute-keys <esc>
  }
}
# cpp: ,, -> <<
hook global WinSetOption filetype=(c|cpp) %{
  hook buffer InsertChar '[,,]' %{
    try %{
      execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
      execute-keys <<
    }
  }
}

# select previous word (bash like)
map global insert <c-w> '<a-;>h<a-;><a-B>'

declare-option -hidden int kak_opt_autowrap_column
set-option global kak_opt_autowrap_column 80
# format with =
map global normal = '|fmt -w $kak_opt_autowrap_column<ret>'

# comment with #
map global normal '#' :comment-line<ret>

# clear search buffer
map global user ',' ': set-register / ""<ret><c-l>: execute-keys "; "<ret>' -docstring 'clear search'

# multiple insert
define-command -params 1 urk %{
    execute-keys -with-hooks \;i.<esc>hd %arg{1} P %arg{1} Hs.<ret><a-space>c
}
map global user i %{:urk %val{count}<ret>} -docstring "countable insert"

# Move mode
# ─────────

declare-user-mode quickmove
map global user 'v' ': enter-user-mode -lock quickmove<ret>'    -docstring 'enter quickmove mode' 
map global quickmove 'k' 'k'          -docstring 'line above'
map global quickmove 'j' 'j'          -docstring 'line below'
map global quickmove 'h' 'h'          -docstring 'left char'
map global quickmove 'l' 'l'          -docstring 'right char'
map global quickmove 'K' '[p;'        -docstring 'paragraph above'
map global quickmove 'J' ']p;'        -docstring 'paragraph below'
map global quickmove '<ret>' ']p;'    -docstring 'paragraph below'
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

# Git mode
# ────────

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
map global user 'g' ': enter-user-mode git<ret>'   -docstring 'enter git mode' 
map global git 'b' ': git-toggle-blame<ret>'       -docstring 'blame (toggle)'
map global git 'l' ': git log<ret>'                -docstring 'log'
map global git 'c' ': git commit<ret>'             -docstring 'commit'
map global git 'd' ': git diff<ret>'               -docstring 'diff'
map global git 's' ': git status<ret>'             -docstring 'status'
map global git 't' ': repl-new tig<ret>'           -docstring 'tig'
map global git 'h' ': git show-diff<ret>'          -docstring 'show diff'
map global git 'H' ': git-hide-diff<ret>'          -docstring 'hide diff'
map global git 'w' ': git-show-blamed-commit<ret>' -docstring 'show blamed commit'
map global git 'L' ': git-log-lines<ret>'          -docstring 'log blame'
# move command
map global git 'n' ': git show-diff<ret>: git next-hunk<ret>' -docstring 'go to next hunk'
map global git 'p' ': git show-diff<ret>: git prev-hunk<ret>' -docstring 'go to prev hunk'

# always show the git indicator, update on save
# # enable flag-lines hl for git diff
# hook global WinCreate .* %{
#     add-highlighter window/git-diff flag-lines Default git_diff_flags
# }
# # trigger update diff if inside git dir
# hook global BufOpenFile .* %{
#     evaluate-commands -draft %sh{
#         cd $(dirname "$kak_buffile")
#         if [ $(git rev-parse --git-dir 2>/dev/null) ]; then
#             for hook in WinCreate BufReload BufWritePost; do
#                 printf "hook buffer -group git-update-diff %s .* 'git update-diff'\n" "$hook"
#             done
#         fi
#     }
# }

# Select next mode
# ────────────────

# declare-user-mode select-next
# map global user '<space>' ': enter-user-mode select-next<ret>' -docstring 'enter select-next mode'
# define-command -override -hidden select-next-param %{
#     execute-keys -save-regs '/' '/[(,]<ret>l<a-i>u'
# }
# map global select-next "'" "f'<a-i>'"                 -docstring "select inside next single quotes"
# map global select-next '"' 'f"<a-i>"'                 -docstring "select inside next double quotes"
# map global select-next ')' 'f(<a-i>)'                 -docstring "select inside next parentheses"
# map global select-next ']' 'f[<a-i>]'                 -docstring "select inside next brackets"
# map global select-next '}' 'f{<a-i>}'                 -docstring "select inside next braces"
# map global select-next '>' 'f<lt><a-i><gt>'           -docstring "select inside next angles"
# map global select-next 'u' ': select-next-param<ret>' -docstring "select next argument"
# map global select-next 'p' ']pj<a-i>p'                -docstring "select inside next angles"

# Enable <tab>/<s-tab> for insert completion selection
# ──────────────────────────────────────────────────────

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# Filetype specific
# ─────────────────

# C / CPP: CMake build system
 
declare-user-mode cmake
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
  map global user   'c' ': enter-user-mode cmake<ret>'         -docstring 'enter CMake mode'
  map global cmake  'c' ': terminal ccmake -S . -B build<ret>' -docstring 'configure CMake'
  map global cmake  'b' ': eval -draft cmake-build<ret>'       -docstring 'silent build'
  map global cmake  'B' ': cmake-build<ret>'                   -docstring 'verbose build'
  map global cmake  'i' ': eval -draft cmake-install<ret>'     -docstring 'silent install'
  map global cmake  'I' ': cmake-install<ret>'                 -docstring 'verbose install'
  map global cmake  's' ': buffer *CMake*<ret>'                -docstring 'show CMake buffer'
  map global cmake  'd' ': delete-buffer *CMake*<ret>'         -docstring 'delete CMake buffer'
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

# Secure save
# ───────────

define-command -params 0..1 secure_write %{ evaluate-commands %sh{
  if [ -z ${1+x} ]; then
    # no param given: usual write
    echo "write"
  else
    bufname=$1
    if [ -e "${bufname}" ] && [ "${bufname}" != "${current_bufname}" ]; then
      # file already exists and is not the current one
      echo "echo 'Use w! to override existing file'"
    else
      echo "write ${bufname}"
    fi
  fi
}}
unalias global w write
alias global w secure_write

# System clipboard handling
# ─────────────────────────

map global user 'P' '!xsel --output --clipboard <ret>'     -docstring 'paste from clipboard'
map global user 'p' '<a-!>xsel --output --clipboard <ret>' -docstring 'paste from clipboard (after)'

hook global RegisterModified '"' %{ nop %sh{
  printf %s "$kak_main_reg_dquote" | xsel --input --clipboard
}}

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
plug "andreyorst/fzf.kak" %{
  map global normal <c-p> ': fzf-mode<ret>'
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
  map global insert <a-f>    "<esc>: phantom-selection-iterate-next<ret>i"
  map global insert <a-F>    "<esc>: phantom-selection-iterate-prev<ret>i"
}

## Text

# surround
plug "alexherbo2/prelude.kak"
plug "alexherbo2/auto-pairs.kak" %{
  require-module prelude
  require-module auto-pairs
  auto-pairs-enable
}
plug "alexherbo2/word-select.kak" %{
  require-module prelude
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
plug "danr/kakoune-easymotion" %{
  map global user <space> ': enter-user-mode easymotion<ret>' -docstring 'easymotion'
  map global easymotion 'b' ': easy-motion-b<ret>' -docstring 'word ←'
  map global easymotion 'B' ': easy-motion-B<ret>' -docstring 'Word ←'
  unmap global easymotion 'q'
  unmap global easymotion 'Q'

  set-face global EasyMotionForeground rgb:000000,rgb:ff0000
}

# digits vim like
plug "Screwtapello/kakoune-inc-dec" domain "gitlab.com" %{
  map global normal <c-a> ': inc-dec-modify-numbers + %val{count}<ret>'
  map global normal <c-x> ': inc-dec-modify-numbers - %val{count}<ret>'
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
      set-option global lsp_server_configuration pyls.configurationSources=["flake8"]
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

