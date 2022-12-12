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

# Indicators
# ──────────

# always show the git indicator, update on save
# enable flag-lines hl for git diff
hook global WinCreate .* %{
    add-highlighter window/git-diff flag-lines Default git_diff_flags
}
# trigger update diff if inside git dir
hook global BufOpenFile .* %{
  evaluate-commands -draft %sh{
    cd $(dirname "$kak_buffile")
    if [ $(git rev-parse --git-dir 2>/dev/null) ]; then
      for hook in WinCreate BufReload BufWritePost; do
        printf "hook buffer -group git-update-diff %s .* 'git update-diff'\n" "$hook"
      done
    fi
  }
}

# Git conflict
# ────────────

map global object m %{c^[<lt>=]{4\,}[^\n]*\n,^[<gt>=]{4\,}[^\n]*\n<ret>} -docstring 'conflict markers'
define-command conflict-use-1 %{
  evaluate-commands -draft %{
    execute-keys <a-h>h/^<lt>{4}<ret><a-x>d
    execute-keys h/^={4}<ret>j
    execute-keys -with-maps <a-a>m
    execute-keys d
  }
} -docstring "resolve a conflict by using the first version"
define-command conflict-use-2 %{
  evaluate-commands -draft %{
    execute-keys j
    execute-keys -with-maps <a-a>m
    execute-keys dh/^>{4}<ret><a-x>d
  }
} -docstring "resolve a conflict by using the second version"

# -----------

define-command -hidden kit-status-select %{
    try %{
        execute-keys '<a-:>x1s^(?:[ !\?ACDMRTUacdmrtu]{2}|\t(?:(?:both )?modified:|added:|new file:|deleted(?: by \w+)?:|renamed:|copied:))?\h+(?:[^\n]+ -> )?([^\n]+)<ret>'
    }
}

define-command -hidden kit-log-select %{
    try %{
        execute-keys 'x2s^[\*|\\ /_]*(\w+)?(\b[0-9a-f]{4,40}\b)<ret><a-:>'
    }
}

hook -group kit-status global WinSetOption filetype=git-status %{
    hook -group kit-status window NormalKey '[JKjk%]|<esc>' kit-status-select
    hook -once -always window WinSetOption filetype=.* %{
        remove-hooks window kit-status
    }
}

hook -group kit-log global WinSetOption filetype=git-log %{
    hook -group kit-log window NormalKey '[JKjk%]|<esc>' kit-log-select
    hook -once -always window WinSetOption filetype=.* %{
        remove-hooks window kit-log
    }
}

map global user G ': git status -bs<ret>' -docstring 'git status'
hook global WinSetOption filetype=git-status %{
    map window normal c ': git commit --verbose '
    map window normal l ': git log --oneline --graph<ret>'
    map window normal d ': -- %val{selections}<a-!><home> git diff '
    map window normal D ': -- %val{selections}<a-!><home> git diff --cached '
    map window normal a ': -- %val{selections}<a-!><home> git add '
    map window normal A ': -- %val{selections}<a-!><home> terminal git add -p '
    map window normal r ': -- %val{selections}<a-!><home> git reset '
    map window normal R ': -- %val{selections}<a-!><home> terminal git reset -p '
    map window normal o ': -- %val{selections}<a-!><home> git checkout '
    map window normal <space> ': git status -bs<ret>'
}
hook global WinSetOption filetype=git-log %{
    map window normal d     ': %val{selections}<a-!><home> git diff '
    map window normal <ret> ': %val{selections}<a-!><home> git show '
    map window normal r     ': %val{selections}<a-!><home> git reset '
    map window normal R     ': %val{selections}<a-!><home> terminal git reset -p '
    map window normal o     ': %val{selections}<a-!><home> git checkout '
}
