declare-user-mode cmake

hook global WinSetOption filetype=(c|cpp|cmake) %{

  # Tools

  define-command -override cmake_set_command %{
    set-option global makecmd "cmake --build %opt{cmake_opt_build_folder} %opt{cmake_opt_config} %opt{cmake_opt_target} %opt{cmake_parallel_command}"
  }

  # Options

  # Build folder (by default: build)
  declare-option -docstring 'build folder'     str cmake_opt_build_folder
  set-option global cmake_opt_build_folder "build"
  define-command -override cmake_set_build_folder -params 1 -file-completion %{
      set-option global cmake_opt_build_folder " %arg{1}"
      cmake_set_command
  }
  map global cmake 'f' ':cmake_set_build_folder ' -docstring 'change build folder'

  # Config: Debug / Release / ReleaseWithDebInfo
  declare-user-mode cmake-config
  declare-option -docstring 'build config' str cmake_opt_config
  set-option global cmake_opt_config " "
  define-command -override cmake_set_config -params 1 %{
      set-option global cmake_opt_config " %arg{1}"
      cmake_set_command
  }
  map global cmake 'c' ': enter-user-mode cmake-config<ret>'    -docstring 'enter config mode'
  map global cmake-config 'd' ': cmake_set_config "--config Debug"<ret>'   -docstring 'set config to Debug'
  map global cmake-config 'r' ': cmake_set_config "--config Release"<ret>' -docstring 'set config to Release'
  map global cmake-config 'n' ': cmake_set_config ""<ret>' -docstring 'set no config'

  # Target (for multi-target generators)
  declare-user-mode cmake-target
  declare-option -docstring 'build target' str cmake_opt_target
  set-option global cmake_opt_target " "
  define-command -override cmake_set_target -params 1 %{
      set-option global cmake_opt_target " --target %arg{1}"
      cmake_set_command
  }
  map global cmake 't' ': enter-user-mode cmake-target<ret>'    -docstring 'enter target mode'
  map global cmake-target 'a' ': cmake_set_target all<ret>'     -docstring 'set target to all'
  map global cmake-target 'i' ': cmake_set_target install<ret>' -docstring 'set target to install'

  # parallel mode (useless with ninja)
  declare-option -docstring 'nb paralell jobs' str cmake_parallel_command
  set-option global cmake_parallel_command " "
  define-command -override cmake_set_parallel -params 1 %{
      set-option global cmake_parallel_command " -- -j %arg{1}"
      cmake_set_command
  }
  map global cmake 'p' ':cmake_set_parallel ' -docstring 'parallelism level'

  # main block
  map global user   'c' ': enter-user-mode cmake<ret>'                                -docstring 'enter CMake mode'
  map global cmake  'g' ': terminal ccmake -S . -B %opt{cmake_opt_build_folder}<ret>' -docstring 'gui CMake'
  map global cmake  's' ': buffer *make*<ret>'                                        -docstring 'show CMake buffer'
  map global cmake  'd' ': delete-buffer *make*<ret>'                                 -docstring 'delete CMake buffer'
  map global cmake  'P' ': echo %opt{makecmd}<ret>'                                   -docstring 'print command'
  map global cmake  'b' ': eval -draft make<ret>'                                     -docstring 'build (background)'
  map global cmake  'B' ': make<ret>'                                                 -docstring 'build'

  # Init

  # reset the makecmd
  cmake_set_command

}
