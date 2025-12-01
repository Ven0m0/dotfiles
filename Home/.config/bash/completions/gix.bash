_gix() {
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
        cmd="gix"
        ;;
      gix,archive)
        cmd="gix__archive"
        ;;
      gix,attributes)
        cmd="gix__attributes"
        ;;
      gix,attrs)
        cmd="gix__attributes"
        ;;
      gix,blame)
        cmd="gix__blame"
        ;;
      gix,cat)
        cmd="gix__cat"
        ;;
      gix,clean)
        cmd="gix__clean"
        ;;
      gix,clone)
        cmd="gix__clone"
        ;;
      gix,commit)
        cmd="gix__commit"
        ;;
      gix,commit-graph)
        cmd="gix__commit__graph"
        ;;
      gix,completions)
        cmd="gix__completions"
        ;;
      gix,config)
        cmd="gix__config"
        ;;
      gix,config-tree)
        cmd="gix__config__tree"
        ;;
      gix,credential)
        cmd="gix__credential"
        ;;
      gix,diff)
        cmd="gix__diff"
        ;;
      gix,env)
        cmd="gix__env"
        ;;
      gix,exclude)
        cmd="gix__exclude"
        ;;
      gix,fetch)
        cmd="gix__fetch"
        ;;
      gix,free)
        cmd="gix__free"
        ;;
      gix,fsck)
        cmd="gix__fsck"
        ;;
      gix,generate-completions)
        cmd="gix__completions"
        ;;
      gix,help)
        cmd="gix__help"
        ;;
      gix,index)
        cmd="gix__index"
        ;;
      gix,is-changed)
        cmd="gix__is__changed"
        ;;
      gix,is-clean)
        cmd="gix__is__clean"
        ;;
      gix,log)
        cmd="gix__log"
        ;;
      gix,mailmap)
        cmd="gix__mailmap"
        ;;
      gix,merge)
        cmd="gix__merge"
        ;;
      gix,merge-base)
        cmd="gix__merge__base"
        ;;
      gix,no-repo)
        cmd="gix__free"
        ;;
      gix,odb)
        cmd="gix__odb"
        ;;
      gix,r)
        cmd="gix__revision"
        ;;
      gix,remote)
        cmd="gix__remote"
        ;;
      gix,remotes)
        cmd="gix__remote"
        ;;
      gix,rev)
        cmd="gix__revision"
        ;;
      gix,revision)
        cmd="gix__revision"
        ;;
      gix,shell-completions)
        cmd="gix__completions"
        ;;
      gix,status)
        cmd="gix__status"
        ;;
      gix,submodule)
        cmd="gix__submodule"
        ;;
      gix,tag)
        cmd="gix__tag"
        ;;
      gix,tags)
        cmd="gix__tag"
        ;;
      gix,tree)
        cmd="gix__tree"
        ;;
      gix,verify)
        cmd="gix__verify"
        ;;
      gix,worktree)
        cmd="gix__worktree"
        ;;
      gix__attributes,help)
        cmd="gix__attributes__help"
        ;;
      gix__attributes,query)
        cmd="gix__attributes__query"
        ;;
      gix__attributes,validate-baseline)
        cmd="gix__attributes__validate__baseline"
        ;;
      gix__attributes__help,help)
        cmd="gix__attributes__help__help"
        ;;
      gix__attributes__help,query)
        cmd="gix__attributes__help__query"
        ;;
      gix__attributes__help,validate-baseline)
        cmd="gix__attributes__help__validate__baseline"
        ;;
      gix__commit,describe)
        cmd="gix__commit__describe"
        ;;
      gix__commit,help)
        cmd="gix__commit__help"
        ;;
      gix__commit,verify)
        cmd="gix__commit__verify"
        ;;
      gix__commit__graph,help)
        cmd="gix__commit__graph__help"
        ;;
      gix__commit__graph,list)
        cmd="gix__commit__graph__list"
        ;;
      gix__commit__graph,verify)
        cmd="gix__commit__graph__verify"
        ;;
      gix__commit__graph__help,help)
        cmd="gix__commit__graph__help__help"
        ;;
      gix__commit__graph__help,list)
        cmd="gix__commit__graph__help__list"
        ;;
      gix__commit__graph__help,verify)
        cmd="gix__commit__graph__help__verify"
        ;;
      gix__commit__help,describe)
        cmd="gix__commit__help__describe"
        ;;
      gix__commit__help,help)
        cmd="gix__commit__help__help"
        ;;
      gix__commit__help,verify)
        cmd="gix__commit__help__verify"
        ;;
      gix__credential,approve)
        cmd="gix__credential__approve"
        ;;
      gix__credential,erase)
        cmd="gix__credential__reject"
        ;;
      gix__credential,fill)
        cmd="gix__credential__fill"
        ;;
      gix__credential,get)
        cmd="gix__credential__fill"
        ;;
      gix__credential,help)
        cmd="gix__credential__help"
        ;;
      gix__credential,reject)
        cmd="gix__credential__reject"
        ;;
      gix__credential,store)
        cmd="gix__credential__approve"
        ;;
      gix__credential__help,approve)
        cmd="gix__credential__help__approve"
        ;;
      gix__credential__help,fill)
        cmd="gix__credential__help__fill"
        ;;
      gix__credential__help,help)
        cmd="gix__credential__help__help"
        ;;
      gix__credential__help,reject)
        cmd="gix__credential__help__reject"
        ;;
      gix__diff,file)
        cmd="gix__diff__file"
        ;;
      gix__diff,help)
        cmd="gix__diff__help"
        ;;
      gix__diff,tree)
        cmd="gix__diff__tree"
        ;;
      gix__diff__help,file)
        cmd="gix__diff__help__file"
        ;;
      gix__diff__help,help)
        cmd="gix__diff__help__help"
        ;;
      gix__diff__help,tree)
        cmd="gix__diff__help__tree"
        ;;
      gix__exclude,help)
        cmd="gix__exclude__help"
        ;;
      gix__exclude,query)
        cmd="gix__exclude__query"
        ;;
      gix__exclude__help,help)
        cmd="gix__exclude__help__help"
        ;;
      gix__exclude__help,query)
        cmd="gix__exclude__help__query"
        ;;
      gix__free,commit-graph)
        cmd="gix__free__commit__graph"
        ;;
      gix__free,discover)
        cmd="gix__free__discover"
        ;;
      gix__free,help)
        cmd="gix__free__help"
        ;;
      gix__free,index)
        cmd="gix__free__index"
        ;;
      gix__free,mailmap)
        cmd="gix__free__mailmap"
        ;;
      gix__free,pack)
        cmd="gix__free__pack"
        ;;
      gix__free__commit__graph,help)
        cmd="gix__free__commit__graph__help"
        ;;
      gix__free__commit__graph,verify)
        cmd="gix__free__commit__graph__verify"
        ;;
      gix__free__commit__graph__help,help)
        cmd="gix__free__commit__graph__help__help"
        ;;
      gix__free__commit__graph__help,verify)
        cmd="gix__free__commit__graph__help__verify"
        ;;
      gix__free__help,commit-graph)
        cmd="gix__free__help__commit__graph"
        ;;
      gix__free__help,discover)
        cmd="gix__free__help__discover"
        ;;
      gix__free__help,help)
        cmd="gix__free__help__help"
        ;;
      gix__free__help,index)
        cmd="gix__free__help__index"
        ;;
      gix__free__help,mailmap)
        cmd="gix__free__help__mailmap"
        ;;
      gix__free__help,pack)
        cmd="gix__free__help__pack"
        ;;
      gix__free__help__commit__graph,verify)
        cmd="gix__free__help__commit__graph__verify"
        ;;
      gix__free__help__index,checkout-exclusive)
        cmd="gix__free__help__index__checkout__exclusive"
        ;;
      gix__free__help__index,from-list)
        cmd="gix__free__help__index__from__list"
        ;;
      gix__free__help__index,info)
        cmd="gix__free__help__index__info"
        ;;
      gix__free__help__index,verify)
        cmd="gix__free__help__index__verify"
        ;;
      gix__free__help__mailmap,verify)
        cmd="gix__free__help__mailmap__verify"
        ;;
      gix__free__help__pack,create)
        cmd="gix__free__help__pack__create"
        ;;
      gix__free__help__pack,explode)
        cmd="gix__free__help__pack__explode"
        ;;
      gix__free__help__pack,index)
        cmd="gix__free__help__pack__index"
        ;;
      gix__free__help__pack,multi-index)
        cmd="gix__free__help__pack__multi__index"
        ;;
      gix__free__help__pack,receive)
        cmd="gix__free__help__pack__receive"
        ;;
      gix__free__help__pack,verify)
        cmd="gix__free__help__pack__verify"
        ;;
      gix__free__help__pack__index,create)
        cmd="gix__free__help__pack__index__create"
        ;;
      gix__free__help__pack__multi__index,create)
        cmd="gix__free__help__pack__multi__index__create"
        ;;
      gix__free__help__pack__multi__index,entries)
        cmd="gix__free__help__pack__multi__index__entries"
        ;;
      gix__free__help__pack__multi__index,info)
        cmd="gix__free__help__pack__multi__index__info"
        ;;
      gix__free__help__pack__multi__index,verify)
        cmd="gix__free__help__pack__multi__index__verify"
        ;;
      gix__free__index,checkout-exclusive)
        cmd="gix__free__index__checkout__exclusive"
        ;;
      gix__free__index,from-list)
        cmd="gix__free__index__from__list"
        ;;
      gix__free__index,help)
        cmd="gix__free__index__help"
        ;;
      gix__free__index,info)
        cmd="gix__free__index__info"
        ;;
      gix__free__index,verify)
        cmd="gix__free__index__verify"
        ;;
      gix__free__index__help,checkout-exclusive)
        cmd="gix__free__index__help__checkout__exclusive"
        ;;
      gix__free__index__help,from-list)
        cmd="gix__free__index__help__from__list"
        ;;
      gix__free__index__help,help)
        cmd="gix__free__index__help__help"
        ;;
      gix__free__index__help,info)
        cmd="gix__free__index__help__info"
        ;;
      gix__free__index__help,verify)
        cmd="gix__free__index__help__verify"
        ;;
      gix__free__mailmap,help)
        cmd="gix__free__mailmap__help"
        ;;
      gix__free__mailmap,verify)
        cmd="gix__free__mailmap__verify"
        ;;
      gix__free__mailmap__help,help)
        cmd="gix__free__mailmap__help__help"
        ;;
      gix__free__mailmap__help,verify)
        cmd="gix__free__mailmap__help__verify"
        ;;
      gix__free__pack,create)
        cmd="gix__free__pack__create"
        ;;
      gix__free__pack,explode)
        cmd="gix__free__pack__explode"
        ;;
      gix__free__pack,help)
        cmd="gix__free__pack__help"
        ;;
      gix__free__pack,index)
        cmd="gix__free__pack__index"
        ;;
      gix__free__pack,multi-index)
        cmd="gix__free__pack__multi__index"
        ;;
      gix__free__pack,receive)
        cmd="gix__free__pack__receive"
        ;;
      gix__free__pack,verify)
        cmd="gix__free__pack__verify"
        ;;
      gix__free__pack__help,create)
        cmd="gix__free__pack__help__create"
        ;;
      gix__free__pack__help,explode)
        cmd="gix__free__pack__help__explode"
        ;;
      gix__free__pack__help,help)
        cmd="gix__free__pack__help__help"
        ;;
      gix__free__pack__help,index)
        cmd="gix__free__pack__help__index"
        ;;
      gix__free__pack__help,multi-index)
        cmd="gix__free__pack__help__multi__index"
        ;;
      gix__free__pack__help,receive)
        cmd="gix__free__pack__help__receive"
        ;;
      gix__free__pack__help,verify)
        cmd="gix__free__pack__help__verify"
        ;;
      gix__free__pack__help__index,create)
        cmd="gix__free__pack__help__index__create"
        ;;
      gix__free__pack__help__multi__index,create)
        cmd="gix__free__pack__help__multi__index__create"
        ;;
      gix__free__pack__help__multi__index,entries)
        cmd="gix__free__pack__help__multi__index__entries"
        ;;
      gix__free__pack__help__multi__index,info)
        cmd="gix__free__pack__help__multi__index__info"
        ;;
      gix__free__pack__help__multi__index,verify)
        cmd="gix__free__pack__help__multi__index__verify"
        ;;
      gix__free__pack__index,create)
        cmd="gix__free__pack__index__create"
        ;;
      gix__free__pack__index,help)
        cmd="gix__free__pack__index__help"
        ;;
      gix__free__pack__index__help,create)
        cmd="gix__free__pack__index__help__create"
        ;;
      gix__free__pack__index__help,help)
        cmd="gix__free__pack__index__help__help"
        ;;
      gix__free__pack__multi__index,create)
        cmd="gix__free__pack__multi__index__create"
        ;;
      gix__free__pack__multi__index,entries)
        cmd="gix__free__pack__multi__index__entries"
        ;;
      gix__free__pack__multi__index,help)
        cmd="gix__free__pack__multi__index__help"
        ;;
      gix__free__pack__multi__index,info)
        cmd="gix__free__pack__multi__index__info"
        ;;
      gix__free__pack__multi__index,verify)
        cmd="gix__free__pack__multi__index__verify"
        ;;
      gix__free__pack__multi__index__help,create)
        cmd="gix__free__pack__multi__index__help__create"
        ;;
      gix__free__pack__multi__index__help,entries)
        cmd="gix__free__pack__multi__index__help__entries"
        ;;
      gix__free__pack__multi__index__help,help)
        cmd="gix__free__pack__multi__index__help__help"
        ;;
      gix__free__pack__multi__index__help,info)
        cmd="gix__free__pack__multi__index__help__info"
        ;;
      gix__free__pack__multi__index__help,verify)
        cmd="gix__free__pack__multi__index__help__verify"
        ;;
      gix__help,archive)
        cmd="gix__help__archive"
        ;;
      gix__help,attributes)
        cmd="gix__help__attributes"
        ;;
      gix__help,blame)
        cmd="gix__help__blame"
        ;;
      gix__help,cat)
        cmd="gix__help__cat"
        ;;
      gix__help,clean)
        cmd="gix__help__clean"
        ;;
      gix__help,clone)
        cmd="gix__help__clone"
        ;;
      gix__help,commit)
        cmd="gix__help__commit"
        ;;
      gix__help,commit-graph)
        cmd="gix__help__commit__graph"
        ;;
      gix__help,completions)
        cmd="gix__help__completions"
        ;;
      gix__help,config)
        cmd="gix__help__config"
        ;;
      gix__help,config-tree)
        cmd="gix__help__config__tree"
        ;;
      gix__help,credential)
        cmd="gix__help__credential"
        ;;
      gix__help,diff)
        cmd="gix__help__diff"
        ;;
      gix__help,env)
        cmd="gix__help__env"
        ;;
      gix__help,exclude)
        cmd="gix__help__exclude"
        ;;
      gix__help,fetch)
        cmd="gix__help__fetch"
        ;;
      gix__help,free)
        cmd="gix__help__free"
        ;;
      gix__help,fsck)
        cmd="gix__help__fsck"
        ;;
      gix__help,help)
        cmd="gix__help__help"
        ;;
      gix__help,index)
        cmd="gix__help__index"
        ;;
      gix__help,is-changed)
        cmd="gix__help__is__changed"
        ;;
      gix__help,is-clean)
        cmd="gix__help__is__clean"
        ;;
      gix__help,log)
        cmd="gix__help__log"
        ;;
      gix__help,mailmap)
        cmd="gix__help__mailmap"
        ;;
      gix__help,merge)
        cmd="gix__help__merge"
        ;;
      gix__help,merge-base)
        cmd="gix__help__merge__base"
        ;;
      gix__help,odb)
        cmd="gix__help__odb"
        ;;
      gix__help,remote)
        cmd="gix__help__remote"
        ;;
      gix__help,revision)
        cmd="gix__help__revision"
        ;;
      gix__help,status)
        cmd="gix__help__status"
        ;;
      gix__help,submodule)
        cmd="gix__help__submodule"
        ;;
      gix__help,tag)
        cmd="gix__help__tag"
        ;;
      gix__help,tree)
        cmd="gix__help__tree"
        ;;
      gix__help,verify)
        cmd="gix__help__verify"
        ;;
      gix__help,worktree)
        cmd="gix__help__worktree"
        ;;
      gix__help__attributes,query)
        cmd="gix__help__attributes__query"
        ;;
      gix__help__attributes,validate-baseline)
        cmd="gix__help__attributes__validate__baseline"
        ;;
      gix__help__commit,describe)
        cmd="gix__help__commit__describe"
        ;;
      gix__help__commit,verify)
        cmd="gix__help__commit__verify"
        ;;
      gix__help__commit__graph,list)
        cmd="gix__help__commit__graph__list"
        ;;
      gix__help__commit__graph,verify)
        cmd="gix__help__commit__graph__verify"
        ;;
      gix__help__credential,approve)
        cmd="gix__help__credential__approve"
        ;;
      gix__help__credential,fill)
        cmd="gix__help__credential__fill"
        ;;
      gix__help__credential,reject)
        cmd="gix__help__credential__reject"
        ;;
      gix__help__diff,file)
        cmd="gix__help__diff__file"
        ;;
      gix__help__diff,tree)
        cmd="gix__help__diff__tree"
        ;;
      gix__help__exclude,query)
        cmd="gix__help__exclude__query"
        ;;
      gix__help__free,commit-graph)
        cmd="gix__help__free__commit__graph"
        ;;
      gix__help__free,discover)
        cmd="gix__help__free__discover"
        ;;
      gix__help__free,index)
        cmd="gix__help__free__index"
        ;;
      gix__help__free,mailmap)
        cmd="gix__help__free__mailmap"
        ;;
      gix__help__free,pack)
        cmd="gix__help__free__pack"
        ;;
      gix__help__free__commit__graph,verify)
        cmd="gix__help__free__commit__graph__verify"
        ;;
      gix__help__free__index,checkout-exclusive)
        cmd="gix__help__free__index__checkout__exclusive"
        ;;
      gix__help__free__index,from-list)
        cmd="gix__help__free__index__from__list"
        ;;
      gix__help__free__index,info)
        cmd="gix__help__free__index__info"
        ;;
      gix__help__free__index,verify)
        cmd="gix__help__free__index__verify"
        ;;
      gix__help__free__mailmap,verify)
        cmd="gix__help__free__mailmap__verify"
        ;;
      gix__help__free__pack,create)
        cmd="gix__help__free__pack__create"
        ;;
      gix__help__free__pack,explode)
        cmd="gix__help__free__pack__explode"
        ;;
      gix__help__free__pack,index)
        cmd="gix__help__free__pack__index"
        ;;
      gix__help__free__pack,multi-index)
        cmd="gix__help__free__pack__multi__index"
        ;;
      gix__help__free__pack,receive)
        cmd="gix__help__free__pack__receive"
        ;;
      gix__help__free__pack,verify)
        cmd="gix__help__free__pack__verify"
        ;;
      gix__help__free__pack__index,create)
        cmd="gix__help__free__pack__index__create"
        ;;
      gix__help__free__pack__multi__index,create)
        cmd="gix__help__free__pack__multi__index__create"
        ;;
      gix__help__free__pack__multi__index,entries)
        cmd="gix__help__free__pack__multi__index__entries"
        ;;
      gix__help__free__pack__multi__index,info)
        cmd="gix__help__free__pack__multi__index__info"
        ;;
      gix__help__free__pack__multi__index,verify)
        cmd="gix__help__free__pack__multi__index__verify"
        ;;
      gix__help__index,entries)
        cmd="gix__help__index__entries"
        ;;
      gix__help__index,from-tree)
        cmd="gix__help__index__from__tree"
        ;;
      gix__help__mailmap,check)
        cmd="gix__help__mailmap__check"
        ;;
      gix__help__mailmap,entries)
        cmd="gix__help__mailmap__entries"
        ;;
      gix__help__merge,commit)
        cmd="gix__help__merge__commit"
        ;;
      gix__help__merge,file)
        cmd="gix__help__merge__file"
        ;;
      gix__help__merge,tree)
        cmd="gix__help__merge__tree"
        ;;
      gix__help__odb,entries)
        cmd="gix__help__odb__entries"
        ;;
      gix__help__odb,info)
        cmd="gix__help__odb__info"
        ;;
      gix__help__odb,stats)
        cmd="gix__help__odb__stats"
        ;;
      gix__help__remote,ref-map)
        cmd="gix__help__remote__ref__map"
        ;;
      gix__help__remote,refs)
        cmd="gix__help__remote__refs"
        ;;
      gix__help__revision,explain)
        cmd="gix__help__revision__explain"
        ;;
      gix__help__revision,list)
        cmd="gix__help__revision__list"
        ;;
      gix__help__revision,previous-branches)
        cmd="gix__help__revision__previous__branches"
        ;;
      gix__help__revision,resolve)
        cmd="gix__help__revision__resolve"
        ;;
      gix__help__submodule,list)
        cmd="gix__help__submodule__list"
        ;;
      gix__help__tag,list)
        cmd="gix__help__tag__list"
        ;;
      gix__help__tree,entries)
        cmd="gix__help__tree__entries"
        ;;
      gix__help__tree,info)
        cmd="gix__help__tree__info"
        ;;
      gix__help__worktree,list)
        cmd="gix__help__worktree__list"
        ;;
      gix__index,entries)
        cmd="gix__index__entries"
        ;;
      gix__index,from-tree)
        cmd="gix__index__from__tree"
        ;;
      gix__index,help)
        cmd="gix__index__help"
        ;;
      gix__index,read-tree)
        cmd="gix__index__from__tree"
        ;;
      gix__index__help,entries)
        cmd="gix__index__help__entries"
        ;;
      gix__index__help,from-tree)
        cmd="gix__index__help__from__tree"
        ;;
      gix__index__help,help)
        cmd="gix__index__help__help"
        ;;
      gix__mailmap,check)
        cmd="gix__mailmap__check"
        ;;
      gix__mailmap,entries)
        cmd="gix__mailmap__entries"
        ;;
      gix__mailmap,help)
        cmd="gix__mailmap__help"
        ;;
      gix__mailmap__help,check)
        cmd="gix__mailmap__help__check"
        ;;
      gix__mailmap__help,entries)
        cmd="gix__mailmap__help__entries"
        ;;
      gix__mailmap__help,help)
        cmd="gix__mailmap__help__help"
        ;;
      gix__merge,commit)
        cmd="gix__merge__commit"
        ;;
      gix__merge,file)
        cmd="gix__merge__file"
        ;;
      gix__merge,help)
        cmd="gix__merge__help"
        ;;
      gix__merge,tree)
        cmd="gix__merge__tree"
        ;;
      gix__merge__help,commit)
        cmd="gix__merge__help__commit"
        ;;
      gix__merge__help,file)
        cmd="gix__merge__help__file"
        ;;
      gix__merge__help,help)
        cmd="gix__merge__help__help"
        ;;
      gix__merge__help,tree)
        cmd="gix__merge__help__tree"
        ;;
      gix__odb,entries)
        cmd="gix__odb__entries"
        ;;
      gix__odb,help)
        cmd="gix__odb__help"
        ;;
      gix__odb,info)
        cmd="gix__odb__info"
        ;;
      gix__odb,statistics)
        cmd="gix__odb__stats"
        ;;
      gix__odb,stats)
        cmd="gix__odb__stats"
        ;;
      gix__odb__help,entries)
        cmd="gix__odb__help__entries"
        ;;
      gix__odb__help,help)
        cmd="gix__odb__help__help"
        ;;
      gix__odb__help,info)
        cmd="gix__odb__help__info"
        ;;
      gix__odb__help,stats)
        cmd="gix__odb__help__stats"
        ;;
      gix__remote,help)
        cmd="gix__remote__help"
        ;;
      gix__remote,ref-map)
        cmd="gix__remote__ref__map"
        ;;
      gix__remote,refs)
        cmd="gix__remote__refs"
        ;;
      gix__remote__help,help)
        cmd="gix__remote__help__help"
        ;;
      gix__remote__help,ref-map)
        cmd="gix__remote__help__ref__map"
        ;;
      gix__remote__help,refs)
        cmd="gix__remote__help__refs"
        ;;
      gix__revision,e)
        cmd="gix__revision__explain"
        ;;
      gix__revision,explain)
        cmd="gix__revision__explain"
        ;;
      gix__revision,help)
        cmd="gix__revision__help"
        ;;
      gix__revision,l)
        cmd="gix__revision__list"
        ;;
      gix__revision,list)
        cmd="gix__revision__list"
        ;;
      gix__revision,p)
        cmd="gix__revision__resolve"
        ;;
      gix__revision,parse)
        cmd="gix__revision__resolve"
        ;;
      gix__revision,prev)
        cmd="gix__revision__previous__branches"
        ;;
      gix__revision,previous-branches)
        cmd="gix__revision__previous__branches"
        ;;
      gix__revision,query)
        cmd="gix__revision__resolve"
        ;;
      gix__revision,resolve)
        cmd="gix__revision__resolve"
        ;;
      gix__revision__help,explain)
        cmd="gix__revision__help__explain"
        ;;
      gix__revision__help,help)
        cmd="gix__revision__help__help"
        ;;
      gix__revision__help,list)
        cmd="gix__revision__help__list"
        ;;
      gix__revision__help,previous-branches)
        cmd="gix__revision__help__previous__branches"
        ;;
      gix__revision__help,resolve)
        cmd="gix__revision__help__resolve"
        ;;
      gix__submodule,help)
        cmd="gix__submodule__help"
        ;;
      gix__submodule,list)
        cmd="gix__submodule__list"
        ;;
      gix__submodule__help,help)
        cmd="gix__submodule__help__help"
        ;;
      gix__submodule__help,list)
        cmd="gix__submodule__help__list"
        ;;
      gix__tag,help)
        cmd="gix__tag__help"
        ;;
      gix__tag,list)
        cmd="gix__tag__list"
        ;;
      gix__tag__help,help)
        cmd="gix__tag__help__help"
        ;;
      gix__tag__help,list)
        cmd="gix__tag__help__list"
        ;;
      gix__tree,entries)
        cmd="gix__tree__entries"
        ;;
      gix__tree,help)
        cmd="gix__tree__help"
        ;;
      gix__tree,info)
        cmd="gix__tree__info"
        ;;
      gix__tree__help,entries)
        cmd="gix__tree__help__entries"
        ;;
      gix__tree__help,help)
        cmd="gix__tree__help__help"
        ;;
      gix__tree__help,info)
        cmd="gix__tree__help__info"
        ;;
      gix__worktree,help)
        cmd="gix__worktree__help"
        ;;
      gix__worktree,list)
        cmd="gix__worktree__list"
        ;;
      gix__worktree__help,help)
        cmd="gix__worktree__help__help"
        ;;
      gix__worktree__help,list)
        cmd="gix__worktree__help__list"
        ;;
      *) ;;
    esac
  done

  case "$cmd" in
    gix)
      opts="-r -c -t -v -s -f -h -V --repository --config --threads --verbose --trace --no-verbose --progress --strict --progress-keep-open --format --object-hash --help --version archive clean commit-graph odb fsck tree commit tag tags verify revision rev r credential fetch clone mailmap remote remotes attributes attrs exclude index submodule cat is-clean is-changed config-tree status config merge-base merge env diff log worktree free no-repo blame completions generate-completions shell-completions help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --repository)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -r)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --config)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -c)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --threads)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -t)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --format)
          COMPREPLY=("$(compgen -W "human json" -- "$cur")")
          return 0
          ;;
        -f)
          COMPREPLY=("$(compgen -W "human json" -- "$cur")")
          return 0
          ;;
        --object-hash)
          COMPREPLY=("$(compgen -W "SHA1" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__archive)
      opts="-f -l -p -v -h --format --prefix --compression-level --add-path --add-virtual-file --help <OUTPUT_FILE> [TREEISH]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --format)
          COMPREPLY=("$(compgen -W "internal tar tar-gz zip" -- "$cur")")
          return 0
          ;;
        -f)
          COMPREPLY=("$(compgen -W "internal tar tar-gz zip" -- "$cur")")
          return 0
          ;;
        --prefix)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --compression-level)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -l)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --add-path)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -p)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --add-virtual-file)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -v)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__attributes)
      opts="-h --help validate-baseline query help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__attributes__help)
      opts="validate-baseline query help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__attributes__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__attributes__help__query)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__attributes__help__validate__baseline)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__attributes__query)
      opts="-s -h --statistics --help [PATHSPEC]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__attributes__validate__baseline)
      opts="-s -h --statistics --no-ignore --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__blame)
      opts="-s -L -h --statistics --since --help <FILE>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        -L)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --since)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__cat)
      opts="-h --help <REVSPEC>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__clean)
      opts="-n -e -x -p -d -r -m -h --debug --dry-run --execute --ignored --precious --directories --repositories --pathspec-matches-result --skip-hidden-repositories --find-untracked-repositories --help [PATHSPEC]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --skip-hidden-repositories)
          COMPREPLY=("$(compgen -W "all non-bare" -- "$cur")")
          return 0
          ;;
        --find-untracked-repositories)
          COMPREPLY=("$(compgen -W "all non-bare" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__clone)
      opts="-H -h --handshake-info --bare --no-tags --depth --shallow-since --shallow-exclude --ref --help <REMOTE> [DIRECTORY]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --depth)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --shallow-since)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --shallow-exclude)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --ref)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit)
      opts="-h --help verify describe help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__graph)
      opts="-h --help verify list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__graph__help)
      opts="verify list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__graph__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__graph__help__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__graph__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__graph__list)
      opts="-l -h --long-hashes --help [SPEC]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__graph__verify)
      opts="-s -h --statistics --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__describe)
      opts="-t -a -f -l -c -s -d -h --annotated-tags --all-refs --first-parent --long --max-candidates --statistics --always --dirty-suffix --help [REV_SPEC]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --max-candidates)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -c)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --dirty-suffix)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -d)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__help)
      opts="verify describe help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__help__describe)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__commit__verify)
      opts="-h --help [REV_SPEC]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__completions)
      opts="-s -h --shell --help [OUT_DIR]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --shell)
          COMPREPLY=("$(compgen -W "bash elvish fish powershell zsh" -- "$cur")")
          return 0
          ;;
        -s)
          COMPREPLY=("$(compgen -W "bash elvish fish powershell zsh" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__config)
      opts="-h --help [FILTER]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__config__tree)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential)
      opts="-h --help fill get approve store reject erase help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__approve)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__fill)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__help)
      opts="fill approve reject help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__help__approve)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__help__fill)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__help__reject)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__credential__reject)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__diff)
      opts="-h --help tree file help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__diff__file)
      opts="-h --help <OLD_REVSPEC> <NEW_REVSPEC>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__diff__help)
      opts="tree file help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__diff__help__file)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__diff__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__diff__help__tree)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__diff__tree)
      opts="-h --help <OLD_TREEISH> <NEW_TREEISH>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__env)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__exclude)
      opts="-h --help query help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__exclude__help)
      opts="query help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__exclude__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__exclude__help__query)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__exclude__query)
      opts="-s -i -p -h --statistics --show-ignore-patterns --patterns --help [PATHSPEC]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --patterns)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -p)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__fetch)
      opts="-n -H -s -g -r -h --dry-run --handshake-info --negotiation-info --open-negotiation-graph --depth --deepen --shallow-since --shallow-exclude --unshallow --remote --help [REF_SPEC]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --open-negotiation-graph)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -g)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --depth)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --deepen)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --shallow-since)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --shallow-exclude)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --remote)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -r)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free)
      opts="-h --help commit-graph mailmap pack index discover help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__commit__graph)
      opts="-h --help verify help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__commit__graph__help)
      opts="verify help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__commit__graph__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__commit__graph__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__commit__graph__verify)
      opts="-s -h --statistics --help <PATH>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__discover)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help)
      opts="commit-graph mailmap pack index discover help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__commit__graph)
      opts="verify"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__commit__graph__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__discover)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__index)
      opts="from-list verify info checkout-exclusive"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__index__checkout__exclusive)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__index__from__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__index__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__index__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__mailmap)
      opts="verify"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__mailmap__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack)
      opts="index multi-index create receive explode verify"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__explode)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__index)
      opts="create"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__index__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__multi__index)
      opts="entries info verify create"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__multi__index__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__multi__index__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__multi__index__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__multi__index__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__receive)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__help__pack__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index)
      opts="-i -h --object-hash --index-path --help from-list verify info checkout-exclusive help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --object-hash)
          COMPREPLY=("$(compgen -W "SHA1" -- "$cur")")
          return 0
          ;;
        --index-path)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -i)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__checkout__exclusive)
      opts="-r -k -e -h --repository --keep-going --empty-files --help <DIRECTORY>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --repository)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -r)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__from__list)
      opts="-f -i -s -h --force --index-output-path --skip-hash --help <FILE>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --index-output-path)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -i)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__help)
      opts="from-list verify info checkout-exclusive help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__help__checkout__exclusive)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__help__from__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__help__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__info)
      opts="-h --no-details --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__index__verify)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__mailmap)
      opts="-p -h --path --help verify help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --path)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -p)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__mailmap__help)
      opts="verify help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__mailmap__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__mailmap__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__mailmap__verify)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack)
      opts="-h --help index multi-index create receive explode verify help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__create)
      opts="-r -e -s -o -h --repository --expansion --counting-threads --nondeterministic-count --statistics --pack-cache-size-mb --object-cache-size-mb --thin --output-directory --help [TIPS]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --repository)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -r)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --expansion)
          COMPREPLY=("$(compgen -W "none tree-traversal tree-diff" -- "$cur")")
          return 0
          ;;
        -e)
          COMPREPLY=("$(compgen -W "none tree-traversal tree-diff" -- "$cur")")
          return 0
          ;;
        --counting-threads)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --pack-cache-size-mb)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --object-cache-size-mb)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --output-directory)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -o)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__explode)
      opts="-c -h --verify --delete-pack --check --sink-compress --help <PACK_PATH> [OBJECT_PATH]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --check)
          COMPREPLY=("$(compgen -W "all skip-file-checksum skip-file-and-object-checksum skip-file-and-object-checksum-and-no-abort-on-decode" -- "$cur")")
          return 0
          ;;
        -c)
          COMPREPLY=("$(compgen -W "all skip-file-checksum skip-file-and-object-checksum skip-file-and-object-checksum-and-no-abort-on-decode" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help)
      opts="index multi-index create receive explode verify help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__explode)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__index)
      opts="create"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__index__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__multi__index)
      opts="entries info verify create"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__multi__index__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__multi__index__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__multi__index__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__multi__index__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__receive)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__index)
      opts="-h --help create help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__index__create)
      opts="-i -p -h --iteration-mode --pack-path --help [DIRECTORY]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --iteration-mode)
          COMPREPLY=("$(compgen -W "as-is verify restore" -- "$cur")")
          return 0
          ;;
        -i)
          COMPREPLY=("$(compgen -W "as-is verify restore" -- "$cur")")
          return 0
          ;;
        --pack-path)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -p)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__index__help)
      opts="create help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__index__help__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__index__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index)
      opts="-i -h --multi-index-path --help entries info verify create help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --multi-index-path)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -i)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__create)
      opts="-h --help <INDEX_PATHS>..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__entries)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__help)
      opts="entries info verify create help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__help__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__help__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__help__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__info)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__multi__index__verify)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__receive)
      opts="-p -d -r -h --protocol --refs-directory --reference --help <URL> [DIRECTORY]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --protocol)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -p)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --refs-directory)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -d)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --reference)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -r)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__free__pack__verify)
      opts="-s -a -h --statistics --algorithm --decode --re-encode --help <PATH>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --algorithm)
          COMPREPLY=("$(compgen -W "less-time less-memory" -- "$cur")")
          return 0
          ;;
        -a)
          COMPREPLY=("$(compgen -W "less-time less-memory" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__fsck)
      opts="-h --help [SPEC]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help)
      opts="archive clean commit-graph odb fsck tree commit tag verify revision credential fetch clone mailmap remote attributes exclude index submodule cat is-clean is-changed config-tree status config merge-base merge env diff log worktree free blame completions help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__archive)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__attributes)
      opts="validate-baseline query"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__attributes__query)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__attributes__validate__baseline)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__blame)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__cat)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__clean)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__clone)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__commit)
      opts="verify describe"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__commit__graph)
      opts="verify list"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__commit__graph__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__commit__graph__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__commit__describe)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__commit__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__completions)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__config)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__config__tree)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__credential)
      opts="fill approve reject"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__credential__approve)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__credential__fill)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__credential__reject)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__diff)
      opts="tree file"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__diff__file)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__diff__tree)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__env)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__exclude)
      opts="query"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__exclude__query)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__fetch)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free)
      opts="commit-graph mailmap pack index discover"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__commit__graph)
      opts="verify"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__commit__graph__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__discover)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__index)
      opts="from-list verify info checkout-exclusive"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__index__checkout__exclusive)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__index__from__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__index__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__index__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__mailmap)
      opts="verify"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__mailmap__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack)
      opts="index multi-index create receive explode verify"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__explode)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__index)
      opts="create"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__index__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__multi__index)
      opts="entries info verify create"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__multi__index__create)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__multi__index__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__multi__index__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__multi__index__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 6 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__receive)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__free__pack__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__fsck)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__index)
      opts="entries from-tree"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__index__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__index__from__tree)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__is__changed)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__is__clean)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__log)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__mailmap)
      opts="entries check"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__mailmap__check)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__mailmap__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__merge)
      opts="file tree commit"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__merge__base)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__merge__commit)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__merge__file)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__merge__tree)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__odb)
      opts="entries info stats"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__odb__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__odb__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__odb__stats)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__remote)
      opts="refs ref-map"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__remote__ref__map)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__remote__refs)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__revision)
      opts="list explain resolve previous-branches"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__revision__explain)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__revision__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__revision__previous__branches)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__revision__resolve)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__status)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__submodule)
      opts="list"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__submodule__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__tag)
      opts="list"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__tag__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__tree)
      opts="entries info"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__tree__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__tree__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__verify)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__worktree)
      opts="list"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__help__worktree__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__index)
      opts="-h --help entries from-tree read-tree help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__index__entries)
      opts="-f -i -r -s -h --format --no-attributes --attributes-from-index --recurse-submodules --statistics --help [PATHSPEC]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --format)
          COMPREPLY=("$(compgen -W "simple rich" -- "$cur")")
          return 0
          ;;
        -f)
          COMPREPLY=("$(compgen -W "simple rich" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__index__from__tree)
      opts="-f -i -s -h --force --index-output-path --skip-hash --help <SPEC>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --index-output-path)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -i)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__index__help)
      opts="entries from-tree help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__index__help__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__index__help__from__tree)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__index__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__is__changed)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__is__clean)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__log)
      opts="-h --help [PATHSPEC]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__mailmap)
      opts="-h --help entries check help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__mailmap__check)
      opts="-h --help [CONTACTS]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__mailmap__entries)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__mailmap__help)
      opts="entries check help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__mailmap__help__check)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__mailmap__help__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__mailmap__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge)
      opts="-h --help file tree commit help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__base)
      opts="-h --help <FIRST> [OTHERS]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__commit)
      opts="-m -f -t -d -h --in-memory --file-favor --tree-favor --debug --help <OURS> <THEIRS>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --file-favor)
          COMPREPLY=("$(compgen -W "ours theirs" -- "$cur")")
          return 0
          ;;
        -f)
          COMPREPLY=("$(compgen -W "ours theirs" -- "$cur")")
          return 0
          ;;
        --tree-favor)
          COMPREPLY=("$(compgen -W "ancestor ours" -- "$cur")")
          return 0
          ;;
        -t)
          COMPREPLY=("$(compgen -W "ancestor ours" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__file)
      opts="-c -h --resolve-with --help <OURS> <BASE> <THEIRS>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --resolve-with)
          COMPREPLY=("$(compgen -W "union ours theirs" -- "$cur")")
          return 0
          ;;
        -c)
          COMPREPLY=("$(compgen -W "union ours theirs" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__help)
      opts="file tree commit help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__help__commit)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__help__file)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__help__tree)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__merge__tree)
      opts="-m -f -t -d -h --in-memory --file-favor --tree-favor --debug --help <OURS> <BASE> <THEIRS>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --file-favor)
          COMPREPLY=("$(compgen -W "ours theirs" -- "$cur")")
          return 0
          ;;
        -f)
          COMPREPLY=("$(compgen -W "ours theirs" -- "$cur")")
          return 0
          ;;
        --tree-favor)
          COMPREPLY=("$(compgen -W "ancestor ours" -- "$cur")")
          return 0
          ;;
        -t)
          COMPREPLY=("$(compgen -W "ancestor ours" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb)
      opts="-h --help entries info stats statistics help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__entries)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__help)
      opts="entries info stats help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__help__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__help__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__help__stats)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__info)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__odb__stats)
      opts="-h --extra-header-lookup --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__remote)
      opts="-n -H -h --name --handshake-info --help refs ref-map help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --name)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -n)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__remote__help)
      opts="refs ref-map help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__remote__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__remote__help__ref__map)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__remote__help__refs)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__remote__ref__map)
      opts="-u -h --show-unmapped-remote-refs --help [REF_SPEC]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__remote__refs)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision)
      opts="-h --help list l explain e resolve query parse p previous-branches prev help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__explain)
      opts="-h --help <SPEC>"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__help)
      opts="list explain resolve previous-branches help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__help__explain)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__help__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__help__previous__branches)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__help__resolve)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__list)
      opts="-l -s -h --long-hashes --limit --svg --help [SPEC]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --limit)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        --svg)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -s)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__previous__branches)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__revision__resolve)
      opts="-e -r -c -b -t -h --explain --reference --cat-file --blob-format --tree-mode --help <SPECS>..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --blob-format)
          COMPREPLY=("$(compgen -W "git worktree diff diff-or-git" -- "$cur")")
          return 0
          ;;
        -b)
          COMPREPLY=("$(compgen -W "git worktree diff diff-or-git" -- "$cur")")
          return 0
          ;;
        --tree-mode)
          COMPREPLY=("$(compgen -W "raw pretty" -- "$cur")")
          return 0
          ;;
        -t)
          COMPREPLY=("$(compgen -W "raw pretty" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__status)
      opts="-f -s -h --format --ignored --submodules --statistics --no-write --index-worktree-renames --help [PATHSPEC]..."
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --format)
          COMPREPLY=("$(compgen -W "simplified porcelain-v2" -- "$cur")")
          return 0
          ;;
        -f)
          COMPREPLY=("$(compgen -W "simplified porcelain-v2" -- "$cur")")
          return 0
          ;;
        --ignored)
          COMPREPLY=("$(compgen -W "collapsed matching" -- "$cur")")
          return 0
          ;;
        --submodules)
          COMPREPLY=("$(compgen -W "all ref-change modifications none" -- "$cur")")
          return 0
          ;;
        --index-worktree-renames)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__submodule)
      opts="-h --help list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__submodule__help)
      opts="list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__submodule__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__submodule__help__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__submodule__list)
      opts="-d -h --dirty-suffix --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --dirty-suffix)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        -d)
          COMPREPLY=("$(compgen -f "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tag)
      opts="-h --help list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tag__help)
      opts="list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tag__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tag__help__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tag__list)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tree)
      opts="-h --help entries info help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tree__entries)
      opts="-r -e -h --recursive --extended --help [TREEISH]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tree__help)
      opts="entries info help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tree__help__entries)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tree__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tree__help__info)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__tree__info)
      opts="-e -h --extended --help [TREEISH]"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__verify)
      opts="-s -a -h --statistics --algorithm --decode --re-encode --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        --algorithm)
          COMPREPLY=("$(compgen -W "less-time less-memory" -- "$cur")")
          return 0
          ;;
        -a)
          COMPREPLY=("$(compgen -W "less-time less-memory" -- "$cur")")
          return 0
          ;;
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__worktree)
      opts="-h --help list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__worktree__help)
      opts="list help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__worktree__help__help)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__worktree__help__list)
      opts=""
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
        *)
          COMPREPLY=()
          ;;
      esac
      COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
      return 0
      ;;
    gix__worktree__list)
      opts="-h --help"
      if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
        COMPREPLY=("$(compgen -W "$opts" -- "$cur")")
        return 0
      fi
      case "$prev" in
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
  complete -F _gix -o nosort -o bashdefault -o default gix
else
  complete -F _gix -o bashdefault -o default gix
fi
