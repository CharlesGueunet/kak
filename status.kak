# Status line
# ───────────

# buffers
declare-option str modeline_buf_nb    ''
hook global WinCreate .* %{
    hook window NormalIdle .* %{ evaluate-commands %sh{
      buf_nb=$(echo "${kak_buflist}" | wc -w)
      printf 'set window modeline_buf_nb %%{%s}' "${buf_nb}"
    } }
}
# color depends on mode
hook -group multiple-cursors-warning global NormalIdle .* %{
    evaluate-commands %sh{
        if [ "$kak_selection_count" -gt 1 ]; then
            echo "set-face window StatusLine default,rgb:ff7f7f"
        else
            echo "unset-face window StatusLine"
        fi
    }
}

# git branch
declare-option str modeline_git_start  ''
declare-option str modeline_git_logo   ''
declare-option str modeline_git_branch ''
hook global WinCreate .* %{
    # Done in two pass to deal with colors
    hook window NormalIdle .* %{ evaluate-commands %sh{
        repo=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --git-dir 2> /dev/null)
        if [ -n "${repo}" ]; then
            printf 'set window modeline_git_start ""'
        else
            printf 'set window modeline_git_start ""'
        fi
    } }
    hook window NormalIdle .* %{ evaluate-commands %sh{
        repo=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --git-dir 2> /dev/null)
        if [ -n "${repo}" ]; then
            printf 'set window modeline_git_logo "\ue727 "'
        else
            printf 'set window modeline_git_logo ""'
        fi
    } }
    hook window NormalIdle .* %{ evaluate-commands %sh{
        branch=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
        if [ -n "${branch}" ]; then
            printf 'set window modeline_git_branch %%{%s}' " ${branch}"
        else
            printf 'set window modeline_git_branch ""'
        fi
    } }
}

# Make / Grep indicator
declare-option str modeline_fifo_status ''
hook global BufOpenFifo .* %{
  set-option global modeline_fifo_status '●'
}
hook global BufCloseFifo .* %{
  set-option global modeline_fifo_status ' '
  echo "done"
}

# left to right
set-option global modelinefmt ''
set-option -add global modelinefmt '{red}%opt{modeline_fifo_status}'
set-option -add global modelinefmt ' {{context_info}}'
set-option -add global modelinefmt ' {{mode_info}}'
set-option -add global modelinefmt ' {yellow,default}{black,yellow}¶ {black,white} %val{bufname}{default,white}'
set-option -add global modelinefmt ' {green,white}%opt{modeline_git_start}{white,green}%opt{modeline_git_logo}{black,white}%opt{modeline_git_branch}{default,white} {red,white}{black,red}⚙ {black,white} %val{session}'

set-option global ui_options terminal_set_title=true terminal_title="Edit" terminal_status_on_top=true


