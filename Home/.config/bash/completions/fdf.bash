_fdf(){
  local i cur prev opts cmd
  COMPREPLY=()
  if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
    cur="$2"
  else
    cur="${COMP_WORDS[COMP_CWORD]}"
  fi
  prev="$3"
  cmd=""
  opts=""

  for i in "${COMP_WORDS[@]:0:COMP_CWORD}"; do
    case "${cmd},${i}" in
    ",$1")
      cmd="fdf"
      ;;
    *) ;;
    esac
  done

  case "$cmd" in
  fdf)
    opts="-H -S -s -e -j -a -I -L -g -n -d -p -F -t -h -V --hidden --sort --case-sensitive --extension --threads --absolute-path --include-dirs --follow --nocolour --glob --max-results --depth --generate --full-path --fixed-strings --show-errors --same-file-system --size --type --help --version [PATTERN] [PATH]"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
    fi
    case "$prev" in
    --extension)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    -e)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    --threads)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    -j)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    --max-results)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    -n)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    --depth)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    -d)
      COMPREPLY=("$(compgen -f "$cur")")
      return 0
      ;;
    --generate)
      COMPREPLY=("$(compgen -W "bash elvish fish powershell zsh" -- "$cur")")
      return 0
      ;;
    --size)
      COMPREPLY=("$(compgen -W "100 1k 1ki 10mb 1gb +1m +10mb +1gib -500k -10mb -1gib" -- "$cur")")
      return 0
      ;;
    --type)
      COMPREPLY=("$(compgen -W "d u l f p c b s e x" -- "$cur")")
      return 0
      ;;
    -t)
      COMPREPLY=("$(compgen -W "d u l f p c b s e x" -- "$cur")")
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
    return 0
    ;;
  esac
}

if [[ ${BASH_VERSINFO[0]} -eq 4 && ${BASH_VERSINFO[1]} -ge 4 || ${BASH_VERSINFO[0]} -gt 4 ]]; then
  complete -F _fdf -o nosort -o bashdefault -o default fdf
else
  complete -F _fdf -o bashdefault -o default fdf
fi
