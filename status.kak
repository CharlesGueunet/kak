# Status line
# ───────────

# buffers
# declare-option str modeline_buf_nb    ''
# hook global WinCreate .* %{
#     hook window NormalIdle .* %{ evaluate-commands %sh{
#       buf_nb=$(echo "${kak_buflist}" | wc -w)
#       printf 'set window modeline_buf_nb %%{%s}' "${buf_nb}"
#     } }
# }

# git branch
# declare-option str modeline_git_val    ''
# declare-option str modeline_git_branch ''
# hook global WinCreate .* %{
#     # Done in two pass to deal with colors
#     hook window NormalIdle .* %{ evaluate-commands %sh{
#         repo=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --git-dir 2> /dev/null)
#         if [ -n "${repo}" ]; then
#             printf 'set window modeline_git_val "git:"'
#         else
#             printf 'set window modeline_git_val ""'
#         fi
#     } }
#     hook window NormalIdle .* %{ evaluate-commands %sh{
#         branch=$(cd "$(dirname "${kak_buffile}")" && git rev-parse --abbrev-ref HEAD 2>/dev/null)
#         if [ -n "${branch}" ]; then
#             printf 'set window modeline_git_branch %%{%s}' "${branch}"
#         else
#             printf 'set window modeline_git_branch ""'
#         fi
#     } }
# }

# left to right
set-option global modelinefmt ''
set-option -add global modelinefmt '{{context_info}}'
set-option -add global modelinefmt ' {{mode_info}}'
set-option -add global modelinefmt ' on {green}%val{bufname}{default}'
set-option -add global modelinefmt ' [%val{session}]'
# set-option -add global modelinefmt ' %opt{modeline_git_val}{yellow}%opt{modeline_git_branch}{default} [%val{session}]'

