declare-user-mode cmake

hook global WinSetOption filetype=(c|cpp|cmake) %{

  # Build folder (by default: build)
  declare-option -docstring 'build folder'     str cmake_build_folder
  set-option global cmake_build_folder "build"
  define-command -override cmake_set_build_folder -params 1 -file-completion %{
      set-option global cmake_build_folder " %arg{1}"
  }
  map global cmake 'f' ':cmake_set_build_folder ' -docstring 'change build folder'

  # Config: Debug / Release / ReleaseWithDebInfo
  declare-user-mode cmake-config
  declare-option -docstring 'build config' str cmake_config
  set-option global cmake_config " "
  define-command -override cmake_set_config -params 1 %{
      set-option global cmake_config " --config %arg{1}"
  }
  map global cmake 'c' ': enter-user-mode cmake-config<ret>'    -docstring 'enter config mode'
  map global cmake-config 'd' ': cmake_set_config Debug<ret>'   -docstring 'set config to Debug'
  map global cmake-config 'r' ': cmake_set_config Release<ret>' -docstring 'set config to Release'

  # Target (for multi-target generators)
  declare-user-mode cmake-target
  declare-option -docstring 'build target' str cmake_target
  set-option global cmake_target " "
  define-command -override cmake_set_target -params 1 %{
      set-option global cmake_target " --target %arg{1}"
  }
  map global cmake 't' ': enter-user-mode cmake-target<ret>'    -docstring 'enter target mode'
  map global cmake-target 'a' ': cmake_set_target all<ret>'     -docstring 'set target to all'
  map global cmake-target 'i' ': cmake_set_target install<ret>' -docstring 'set target to install'

  # parallel mode (useless with ninja)
  declare-option -docstring 'nb paralell jobs' str cmake_parallel_command
  set-option global cmake_parallel_command " "
  define-command -override cmake_set_parallel -params 1 %{
      set-option global cmake_parallel_command " -- -j %arg{1}"
  }
  map global cmake 'p' ':cmake_set_parallel ' -docstring 'parallelism level'

  # processing
  declare-option str modeline_build_status_internal ''
  define-command -override -hidden -params 1 cmake-fifo %{
    set-option global modeline_build_status_internal '●'
    evaluate-commands %sh{
      cmake_opt=$1
      fifo_file=$(mktemp -d "${TMPDIR:-/tmp}"/kak-build.XXXXXXXX)/fifo
      mkfifo ${fifo_file}
      ( cmake ${cmake_opt} > $fifo_file 2>&1 && notify-send "CMake sucess" || notify-send -u critical "CMake failed" & ) > /dev/null 2>&1 < /dev/null
      printf %s\\n "evaluate-commands -try-client '$kak_opt_toolsclient' %{
                edit! -fifo ${fifo_file} *CMake* -scroll
                hook -always -once buffer BufCloseFifo .* %{
                  set-option global modeline_build_status_internal ' '
                  %sh{ rm -r $(dirname ${fifo_file}) }
                }
            }"
    }
  }
  define-command -override cmake-build -docstring "Verbose build" %{
      cmake-fifo "--build %opt{cmake_build_folder} %opt{cmake_config} %opt{cmake_target} %opt{cmake_parallel_command}"
  }
  define-command -override cmake-print -docstring "Show command to execute" %{
      echo "cmake --build %opt{cmake_build_folder} %opt{cmake_config} %opt{cmake_target} %opt{cmake_parallel_command}"
  }

  map global user   'c' ': enter-user-mode cmake<ret>'         -docstring 'enter CMake mode'
  map global cmake  'g' ': terminal ccmake -S . -B build<ret>' -docstring 'gui CMake'
  map global cmake  'b' ': eval -draft cmake-build<ret>'       -docstring 'silent build'
  map global cmake  'B' ': cmake-build<ret>'                   -docstring 'verbose build'
  map global cmake  's' ': buffer *CMake*<ret>'                -docstring 'show CMake buffer'
  map global cmake  'd' ': delete-buffer *CMake*<ret>'         -docstring 'delete CMake buffer'
  map global cmake  'P' ': cmake-print<ret>'                   -docstring 'print command'
}
