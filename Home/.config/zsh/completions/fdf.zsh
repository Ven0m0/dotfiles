#compdef fdf

autoload -U is-at-least

_fdf() {
  typeset -A opt_args
  typeset -a _arguments_options
  local ret=1

  if is-at-least 5.2; then
    _arguments_options=(-s -S -C)
  else
    _arguments_options=(-s -C)
  fi

  local context curcontext="$curcontext" state line
  _arguments "${_arguments_options[@]}" : \
    '-e+[filters based on extension, eg --extension .txt or -E txt]:EXTENSION:_default' \
    '--extension=[filters based on extension, eg --extension .txt or -E txt]:EXTENSION:_default' \
    '-j+[Number of threads to use, defaults to available threads available on your computer]:THREAD_NUM:_default' \
    '--threads=[Number of threads to use, defaults to available threads available on your computer]:THREAD_NUM:_default' \
    '-n+[Retrieves the first eg 10 results, '\''fdf  -n 10 '\''.cache'\'' /]:TOP_N:_default' \
    '--max-results=[Retrieves the first eg 10 results, '\''fdf  -n 10 '\''.cache'\'' /]:TOP_N:_default' \
    '-d+[Retrieves only traverse to x depth]:DEPTH:_default' \
    '--depth=[Retrieves only traverse to x depth]:DEPTH:_default' \
    '--generate=[Generate shell completions]:GENERATE:(bash elvish fish powershell zsh)' \
    '--size=[Filter by file size (supports custom sizes with +/- prefixes)]:SIZE:((100\:"exactly 100 bytes"
1k\:"exactly 1 kilobyte (1000 bytes)"
1ki\:"exactly 1 kibibyte (1024 bytes)"
10mb\:"exactly 10 megabytes"
1gb\:"exactly 1 gigabyte"
+1m\:"larger than 1MB"
+10mb\:"larger than 10MB"
+1gib\:"larger than 1GiB"
-500k\:"smaller than 500KB"
-10mb\:"smaller than 10MB"
-1gib\:"smaller than 1GiB"))' \
    '-t+[Filter by file type]:TYPE_OF:((d\:"Directory"
u\:"Unknown type"
l\:"Symbolic link"
f\:"Regular file"
p\:"Pipe/FIFO"
c\:"Character device"
b\:"Block device"
s\:"Socket"
e\:"Empty file"
x\:"Executable file"))' \
    '--type=[Filter by file type]:TYPE_OF:((d\:"Directory"
u\:"Unknown type"
l\:"Symbolic link"
f\:"Regular file"
p\:"Pipe/FIFO"
c\:"Character device"
b\:"Block device"
s\:"Socket"
e\:"Empty file"
x\:"Executable file"))' \
    '-H[Shows hidden files eg .gitignore or .bashrc, defaults to off]' \
    '--hidden[Shows hidden files eg .gitignore or .bashrc, defaults to off]' \
    '-S[Sort the entries alphabetically (this has quite the performance cost)]' \
    '--sort[Sort the entries alphabetically (this has quite the performance cost)]' \
    '-s[Enable case-sensitive matching, defaults to false]' \
    '--case-sensitive[Enable case-sensitive matching, defaults to false]' \
    '-a[Starts with the directory entered being resolved to full]' \
    '--absolute-path[Starts with the directory entered being resolved to full]' \
    '-I[Include directories, defaults to off]' \
    '--include-dirs[Include directories, defaults to off]' \
    '-L[Include symlinks in traversal,defaults to false]' \
    '--follow[Include symlinks in traversal,defaults to false]' \
    '--nocolour[Disable colouring output when sending to terminal]' \
    '-g[Use a glob pattern,defaults to off]' \
    '--glob[Use a glob pattern,defaults to off]' \
    '-p[Use a full path for regex matching, default to false]' \
    '--full-path[Use a full path for regex matching, default to false]' \
    '(-g --glob)-F[Use a fixed string not a regex, defaults to false]' \
    '(-g --glob)--fixed-strings[Use a fixed string not a regex, defaults to false]' \
    '--show-errors[Show errors when traversing]' \
    '--same-file-system[Only traverse the same filesystem as the starting directory]' \
    '-h[Print help (see more with '\''--help'\'')]' \
    '--help[Print help (see more with '\''--help'\'')]' \
    '-V[Print version]' \
    '--version[Print version]' \
    '::pattern -- Pattern to search for:_default' \
    '::directory -- Path to search (defaults to current working directory):_files -/' \
    && ret=0
}

(($ + functions[_fdf_commands])) \
  || _fdf_commands() {
    local commands
    commands=()
    _describe -t commands 'fdf commands' commands "$@"
  }

if [ "$funcstack[1]" = "_fdf" ]; then
  _fdf "$@"
else
  compdef _fdf fdf
fi
