# Custom mappings
# ───────────────

map global normal \' \"         # quick register mode
map global normal <ret> :       # quick command mode
map global normal <tab> '<a-;>' # switch side
map global normal <%> '<c-s>%'  # Save position before %

# invert q & b
map global normal q b
map global normal Q B
map global normal <a-q> <a-b>
map global normal <a-Q> <a-B>
map global normal b q
map global normal B Q

# use e for words movements
map global normal e 'w"_/[a-zA-Z]<ret><a-i>w'
map global normal E 'W"_?[a-zA-Z]<ret>'
map global normal <a-e> '"_<a-/>[a-zA-Z]<ret><a-i>w'
map global normal <a-E> '"_<a-?>[a-zA-Z]<ret>'

# comment with #
map global normal '#' :comment-line<ret>

# format with =
map global normal = '|fmt -w $kak_opt_autowrap_column<ret>'

# clear search buffer
map global user ',' ': set-register slash \<ret><c-l>: execute-keys ", "<ret>' -docstring 'clear search'

# case insensitive search
map global user '/' '/(?i)' -docstring "case insensitive search"

# esc with jj
hook global InsertChar '[jj]' %{
  try %{
    execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
    execute-keys <esc>
  }
}

# Always select entire lines
map global normal J "Jx"
map global normal K "Kx"

# tab switch completion
hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <s-tab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <s-tab> <c-p> }

# split window
define-command split %{
  new eval buffer %val{bufname} ';'
}
# map global normal <c-r> ": split<ret>"
# map global normal <c-r> %{: with-option windowing_placement horizontal new<ret>}
map global normal <c-r> %{: new<ret>}

# open term
# map global normal <c-t> ": with-option windowing_placement horizontal kks-connect terminal<ret>"
map global normal <c-t> ": kks-connect tmux-repl-horizontal<ret>"

# fuzzy
declare-user-mode fuzzy
map global normal <c-p> %{:enter-user-mode fuzzy<ret>} -docstring "fzf commands"
map global fuzzy b ": kks-connect terminal kks-buffers<ret>"          -docstring "buffers"
map global fuzzy f ": kks-connect terminal kks-files<ret>"            -docstring "files"
map global fuzzy g ": kks-connect terminal kks-grep<ret>"             -docstring "grep"
map global fuzzy <space> ": kks-connect terminal broot<ret>"              -docstring "broot"

# alt + direction (insert mode)
map global insert <a-h> '<a-;><a-h>'
map global insert <a-j> '<a-;>o'
map global insert <a-k> '<a-;>O'
map global insert <a-l> '<a-;><a-l>'

# restore last selection
hook -group backup-selections global NormalIdle .* %{
  set-register b %reg{z}
  execute-keys -draft '"zZ'
}
map -docstring 'Restore selections from the backup register' global user z '"bz'

# sort buffer alphabetically
define-command -override sort-buffers %{
  eval %sh{
    # XXX use uuid to avoid user conflict with root here
    rm /tmp/buflist
    for bufname in $kak_opt_quickbufs $kak_buflist
      do printf "%s\n" "$bufname" >> /tmp/buflist
    done
    cat /tmp/buflist | awk '!seen[$0]++' | grep -v "/tmp/buflist" | sort | tr '\n' ' ' > /tmp/buflist_tmp
    printf "arrange-buffers "
    cat /tmp/buflist_tmp
    rm /tmp/buflist /tmp/buflist_tmp
  }
}

# find file
# define-command find -params 1 -shell-script-candidates %{ find . -type f } %{ edit %arg{1} }

# Safe save
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

# Clipboard
map global user 'P' '!wl-paste <ret>'     -docstring 'paste from clipboard'
map global user 'p' '<a-!>wl-paste <ret>' -docstring 'paste from clipboard (after)'

hook global RegisterModified '"' %{ nop %sh{
 wl-copy -- "$kak_main_reg_dquote" 2> /dev/null
}}

# Vim like
# ----------

map -docstring 'increment selection' global normal <c-a> ': increment-selection %val{count}<ret>'
map -docstring 'decrement selection' global normal <c-x> ': decrement-selection %val{count}<ret>'

define-command -override increment-selection -params 1 -docstring 'increment-selection <count>: increment selection by count' %{
  execute-keys "a+%sh{expr $1 '|' 1}<esc>|{ cat; echo; } | bc<ret>"
}

define-command -override decrement-selection -params 1 -docstring 'decrement-selection <count>: decrement selection by count' %{
  execute-keys "a-%sh{expr $1 '|' 1}<esc>|{ cat; echo; } | bc<ret>"
}

# Custom object selections
# ─────────────────────────

# select previous word (bash like)
# useful for snippets
map global insert <c-w> '<a-;>h<a-;><a-B>'

# Current indented paragraph object
define-command -hidden custom-indented-paragraph %{
  execute-keys -draft -save-regs '' '<a-i>pZ'
  execute-keys '<a-i>i<a-z>i'
}
map -docstring 'Indented paragraph' global object I '<esc>: custom-indented-paragraph<ret>'

# XML tag
map -docstring 'XML tag objet' global object t %{c<lt>([\w.]+)\b[^>]*?(?<lt>!/)>,<lt>/([\w.]+)\b[^>]*?(?<lt>!/)><ret>}
hook global BufCreate .*\.vt.* %{ # VTK file types are XML
  set-option buffer filetype xml
}

# Filetype specific
# ─────────────────

# C / CPP: CMake build system

# ,, -> <<
hook global WinSetOption filetype=(c|cpp) %{
  hook buffer InsertChar '[,,]' %{
    try %{
      execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
      execute-keys <<
    }
  }
}

# ;; -> add ; at the end of the declaration
hook global WinSetOption filetype=(c|cpp) %{
  hook buffer InsertChar '[;;]' %{
    try %{
      execute-keys -draft "hH<a-k>%val{hook_param}%val{hook_param}<ret>d"
      execute-keys -draft "<esc><a-a>(<c-l>A;"
    }
  }
}

# header / source
hook global WinSetOption filetype=(cpp) %{
  map global user -docstring 'alternate header/source' 'a' ':cpp-alternative-file<ret>'
}
hook global WinSetOption filetype=(c) %{
  map global user -docstring 'alternate header/source' 'a' ':c-alternative-file<ret>'
}

# custom function
# ───────────────

define-command -docstring 'Diff the current selections and display result in a new buffer.' \
diff-selections %{
    evaluate-commands %sh{
        eval set -- "$kak_quoted_selections"
        if [ $# -gt 1 ]; then
            echo "$1" > /tmp/a.txt
            echo "$2" > /tmp/b.txt
            diff -uw /tmp/a.txt /tmp/b.txt > /tmp/diff-result.diff
            echo 'edit -existing -readonly /tmp/diff-result.diff'
        else
            echo "echo -debug 'You must have at least 2 selections to compare.'"
        fi
    }
}

define-command -docstring 'Sum selected values.' \
sum %{
  evaluate-commands %sh{
    # add new line to each selection
    nl_selection=""
    for sel in $kak_selections; do
      nl_selection="$sel\n$nl_selection"
    done

    # replace , by . and compute sum
    summed_selection=`echo -e "$nl_selection" | sed 's/,/./g' | awk '{s+=$1} END {printf "%.2f\n", s}'`
    printf 'echo %%{%s}' "${summed_selection}"
   }
}
