function git-opt -d "Optimize git repo"
    git reflog expire --expire=now --all
    and git gc --prune=now --aggressive
    and git repack -a -d --depth=250 --window=250 --write-bitmap-index
    and git clean -fdX
end
