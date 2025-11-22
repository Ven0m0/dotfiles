#compdef gix

autoload -U is-at-least

_gix() {
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
'-r+[The repository to access]:REPOSITORY:_files' \
'--repository=[The repository to access]:REPOSITORY:_files' \
'*-c+[Add these values to the configuration in the form of \`key=value\` or \`key\`]:CONFIG:_default' \
'*--config=[Add these values to the configuration in the form of \`key=value\` or \`key\`]:CONFIG:_default' \
'-t+[The amount of threads to use for some operations]:THREADS:_default' \
'--threads=[The amount of threads to use for some operations]:THREADS:_default' \
'-f+[Determine the format to use when outputting statistics]:FORMAT:(human json)' \
'--format=[Determine the format to use when outputting statistics]:FORMAT:(human json)' \
'--object-hash=[The object format to assume when reading files that don'\''t inherently know about it, or when writing files]:OBJECT_HASH:(SHA1)' \
'-v[Display verbose messages and progress information]' \
'--verbose[Display verbose messages and progress information]' \
'--trace[Display structured \`tracing\` output in a tree-like structure]' \
'(-v --verbose)--no-verbose[Turn off verbose message display for commands where these are shown by default]' \
'(-v --verbose)--progress[Bring up a terminal user interface displaying progress visually]' \
'-s[Don'\''t default malformed configuration flags, but show an error instead. Ignore IO errors as well]' \
'--strict[Don'\''t default malformed configuration flags, but show an error instead. Ignore IO errors as well]' \
'(-v --verbose)--progress-keep-open[The progress TUI will stay up even though the work is already completed]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'-V[Print version]' \
'--version[Print version]' \
":: :_gix_commands" \
"*::: :->gix" \
&& ret=0
    case $state in
    (gix)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-command-$line[1]:"
        case $line[1] in
            (archive)
_arguments "${_arguments_options[@]}" : \
'-f+[Explicitly set the format. Otherwise derived from the suffix of the output file]:FORMAT:((internal\:"An internal format that is for debugging, it should not be persisted and cannot be read back"
tar\:"Use the \`.tar\` file format, uncompressed"
tar-gz\:"Use the \`.tar.gz\` file format, compressed with \`gzip\`"
zip\:"Use the \`.zip\` container format"))' \
'--format=[Explicitly set the format. Otherwise derived from the suffix of the output file]:FORMAT:((internal\:"An internal format that is for debugging, it should not be persisted and cannot be read back"
tar\:"Use the \`.tar\` file format, uncompressed"
tar-gz\:"Use the \`.tar.gz\` file format, compressed with \`gzip\`"
zip\:"Use the \`.zip\` container format"))' \
'--prefix=[Apply the prefix verbatim to any path we add to the archive. Use a trailing \`/\` if prefix is a directory]:PREFIX:_default' \
'-l+[The compression strength to use for \`.zip\` and \`.tar.gz\` archives, valid from 0-9]:COMPRESSION_LEVEL:_default' \
'--compression-level=[The compression strength to use for \`.zip\` and \`.tar.gz\` archives, valid from 0-9]:COMPRESSION_LEVEL:_default' \
'*-p+[Add the given path to the archive. Directories will always be empty]:ADD_PATH:_files' \
'*--add-path=[Add the given path to the archive. Directories will always be empty]:ADD_PATH:_files' \
'*-v+[Add the new file from a slash-separated path, which must happen in pairs of two, first the path, then the content]:ADD_VIRTUAL_FILE:_default' \
'*--add-virtual-file=[Add the new file from a slash-separated path, which must happen in pairs of two, first the path, then the content]:ADD_VIRTUAL_FILE:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':output_file -- The file to write the archive to:_files' \
'::treeish -- The revspec of the commit or tree to traverse, or the tree at `HEAD` if unspecified:_default' \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
'--skip-hidden-repositories=[Enter ignored directories to skip repositories contained within]:SKIP_HIDDEN_REPOSITORIES:(all non-bare)' \
'--find-untracked-repositories=[What kind of repositories to find inside of untracked directories]:FIND_UNTRACKED_REPOSITORIES:(all non-bare)' \
'--debug[Print additional debug information to help understand decisions it made]' \
'-n[A dummy to easy with muscle-memory. This flag is assumed if provided or not, and has no effect]' \
'--dry-run[A dummy to easy with muscle-memory. This flag is assumed if provided or not, and has no effect]' \
'-e[Actually perform the operation, which deletes files on disk without chance of recovery]' \
'--execute[Actually perform the operation, which deletes files on disk without chance of recovery]' \
'-x[Remove ignored (and expendable) files]' \
'--ignored[Remove ignored (and expendable) files]' \
'-p[Remove precious files]' \
'--precious[Remove precious files]' \
'-d[Remove whole directories]' \
'--directories[Remove whole directories]' \
'-r[Remove nested repositories, even outside ignored directories]' \
'--repositories[Remove nested repositories, even outside ignored directories]' \
'-m[Pathspec patterns are used to match the result of the dirwalk, not the dirwalk itself]' \
'--pathspec-matches-result[Pathspec patterns are used to match the result of the dirwalk, not the dirwalk itself]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::pathspec -- The git path specifications to list attributes for, or unset to read from stdin one per line:_default' \
&& ret=0
;;
(commit-graph)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__commit-graph_commands" \
"*::: :->commit-graph" \
&& ret=0

    case $state in
    (commit-graph)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-commit-graph-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
'-s[output statistical information about the graph]' \
'--statistics[output statistical information about the graph]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
'-l[Display long hashes, instead of expensively shortened versions for best performance]' \
'--long-hashes[Display long hashes, instead of expensively shortened versions for best performance]' \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- The rev-spec to list reachable commits from:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__commit-graph__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-commit-graph-help-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(odb)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__odb_commands" \
"*::: :->odb" \
&& ret=0

    case $state in
    (odb)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-odb-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(stats)
_arguments "${_arguments_options[@]}" : \
'--extra-header-lookup[Lookup headers again, but without preloading indices]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(statistics)
_arguments "${_arguments_options[@]}" : \
'--extra-header-lookup[Lookup headers again, but without preloading indices]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__odb__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-odb-help-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(stats)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(fsck)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- A revspec to start the connectivity check from:_default' \
&& ret=0
;;
(tree)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__tree_commands" \
"*::: :->tree" \
&& ret=0

    case $state in
    (tree)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-tree-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
'-r[Traverse the entire tree and its subtrees respectively, not only this tree]' \
'--recursive[Traverse the entire tree and its subtrees respectively, not only this tree]' \
'-e[Provide files size as well. This is expensive as the object is decoded entirely]' \
'--extended[Provide files size as well. This is expensive as the object is decoded entirely]' \
'-h[Print help]' \
'--help[Print help]' \
'::treeish -- The revspec of the tree to traverse, or the tree at `HEAD` if unspecified:_default' \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
'-e[Provide files size as well. This is expensive as the object is decoded entirely]' \
'--extended[Provide files size as well. This is expensive as the object is decoded entirely]' \
'-h[Print help]' \
'--help[Print help]' \
'::treeish -- The revspec of the tree to traverse, or the tree at `HEAD` if unspecified:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__tree__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-tree-help-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(commit)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__commit_commands" \
"*::: :->commit" \
&& ret=0

    case $state in
    (commit)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-commit-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'::rev_spec -- A specification of the revision to verify, or the current `HEAD` if unset:_default' \
&& ret=0
;;
(describe)
_arguments "${_arguments_options[@]}" : \
'-c+[Consider only the given \`n\` candidates. This can take longer, but potentially produces more accurate results]:MAX_CANDIDATES:_default' \
'--max-candidates=[Consider only the given \`n\` candidates. This can take longer, but potentially produces more accurate results]:MAX_CANDIDATES:_default' \
'-d+[Set the suffix to append if the repository is dirty (not counting untracked files)]' \
'--dirty-suffix=[Set the suffix to append if the repository is dirty (not counting untracked files)]' \
'(-a --all-refs)-t[Use annotated tag references only, not all tags]' \
'(-a --all-refs)--annotated-tags[Use annotated tag references only, not all tags]' \
'(-t --annotated-tags)-a[Use all references under the \`ref/\` namespaces, which includes tag references, local and remote branches]' \
'(-t --annotated-tags)--all-refs[Use all references under the \`ref/\` namespaces, which includes tag references, local and remote branches]' \
'-f[Only follow the first parent when traversing the commit graph]' \
'--first-parent[Only follow the first parent when traversing the commit graph]' \
'-l[Always display the long format, even if that would not be necessary as the id is located directly on a reference]' \
'--long[Always display the long format, even if that would not be necessary as the id is located directly on a reference]' \
'-s[Print information on stderr to inform about performance statistics]' \
'--statistics[Print information on stderr to inform about performance statistics]' \
'--always[If there was no way to describe the commit, fallback to using the abbreviated input revision]' \
'-h[Print help]' \
'--help[Print help]' \
'::rev_spec -- A specification of the revision to use, or the current `HEAD` if unset:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__commit__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-commit-help-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(describe)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(tag)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__tag_commands" \
"*::: :->tag" \
&& ret=0

    case $state in
    (tag)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-tag-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__tag__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-tag-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(tags)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__tag_commands" \
"*::: :->tag" \
&& ret=0

    case $state in
    (tag)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-tag-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__tag__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-tag-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'-a+[The algorithm used to verify packs. They differ in costs]:ALGORITHM:(less-time less-memory)' \
'--algorithm=[The algorithm used to verify packs. They differ in costs]:ALGORITHM:(less-time less-memory)' \
'-s[output statistical information]' \
'--statistics[output statistical information]' \
'(--re-encode)--decode[Decode and parse tags, commits and trees to validate their correctness beyond hashing correctly]' \
'--re-encode[Decode and parse tags, commits and trees to validate their correctness, and re-encode them]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
&& ret=0
;;
(revision)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__revision_commands" \
"*::: :->revision" \
&& ret=0

    case $state in
    (revision)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-revision-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'--limit=[How many commits to list at most]:LIMIT:_default' \
'-s+[Write the graph as SVG file to the given path]:SVG:_files' \
'--svg=[Write the graph as SVG file to the given path]:SVG:_files' \
'-l[Display long hashes, instead of expensively shortened versions for best performance]' \
'--long-hashes[Display long hashes, instead of expensively shortened versions for best performance]' \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- The rev-spec to list reachable commits from:_default' \
&& ret=0
;;
(l)
_arguments "${_arguments_options[@]}" : \
'--limit=[How many commits to list at most]:LIMIT:_default' \
'-s+[Write the graph as SVG file to the given path]:SVG:_files' \
'--svg=[Write the graph as SVG file to the given path]:SVG:_files' \
'-l[Display long hashes, instead of expensively shortened versions for best performance]' \
'--long-hashes[Display long hashes, instead of expensively shortened versions for best performance]' \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- The rev-spec to list reachable commits from:_default' \
&& ret=0
;;
(explain)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':spec:_default' \
&& ret=0
;;
(e)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':spec:_default' \
&& ret=0
;;
(resolve)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(parse)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(p)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(previous-branches)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(prev)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__revision__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-revision-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explain)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(resolve)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(previous-branches)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(rev)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__revision_commands" \
"*::: :->revision" \
&& ret=0

    case $state in
    (revision)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-revision-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'--limit=[How many commits to list at most]:LIMIT:_default' \
'-s+[Write the graph as SVG file to the given path]:SVG:_files' \
'--svg=[Write the graph as SVG file to the given path]:SVG:_files' \
'-l[Display long hashes, instead of expensively shortened versions for best performance]' \
'--long-hashes[Display long hashes, instead of expensively shortened versions for best performance]' \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- The rev-spec to list reachable commits from:_default' \
&& ret=0
;;
(l)
_arguments "${_arguments_options[@]}" : \
'--limit=[How many commits to list at most]:LIMIT:_default' \
'-s+[Write the graph as SVG file to the given path]:SVG:_files' \
'--svg=[Write the graph as SVG file to the given path]:SVG:_files' \
'-l[Display long hashes, instead of expensively shortened versions for best performance]' \
'--long-hashes[Display long hashes, instead of expensively shortened versions for best performance]' \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- The rev-spec to list reachable commits from:_default' \
&& ret=0
;;
(explain)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':spec:_default' \
&& ret=0
;;
(e)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':spec:_default' \
&& ret=0
;;
(resolve)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(parse)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(p)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(previous-branches)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(prev)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__revision__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-revision-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explain)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(resolve)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(previous-branches)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(r)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__revision_commands" \
"*::: :->revision" \
&& ret=0

    case $state in
    (revision)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-revision-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'--limit=[How many commits to list at most]:LIMIT:_default' \
'-s+[Write the graph as SVG file to the given path]:SVG:_files' \
'--svg=[Write the graph as SVG file to the given path]:SVG:_files' \
'-l[Display long hashes, instead of expensively shortened versions for best performance]' \
'--long-hashes[Display long hashes, instead of expensively shortened versions for best performance]' \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- The rev-spec to list reachable commits from:_default' \
&& ret=0
;;
(l)
_arguments "${_arguments_options[@]}" : \
'--limit=[How many commits to list at most]:LIMIT:_default' \
'-s+[Write the graph as SVG file to the given path]:SVG:_files' \
'--svg=[Write the graph as SVG file to the given path]:SVG:_files' \
'-l[Display long hashes, instead of expensively shortened versions for best performance]' \
'--long-hashes[Display long hashes, instead of expensively shortened versions for best performance]' \
'-h[Print help]' \
'--help[Print help]' \
'::spec -- The rev-spec to list reachable commits from:_default' \
&& ret=0
;;
(explain)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':spec:_default' \
&& ret=0
;;
(e)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':spec:_default' \
&& ret=0
;;
(resolve)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(parse)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(p)
_arguments "${_arguments_options[@]}" : \
'-b+[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'--blob-format=[How to display blobs]:BLOB_FORMAT:((git\:"The version stored in the Git Object Database"
worktree\:"The version that would be checked out into the worktree, including filters"
diff\:"The version that would be diffed (Worktree + Text-Conversion)"
diff-or-git\:"The version that would be diffed if there is a text-conversion, or the one stored in Git otherwise"))' \
'-t+[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'--tree-mode=[How to display trees as obtained with \`@\:dirname\` or \`@^{tree}\`]:TREE_MODE:((raw\:"Show the raw bytes - only useful for piping into files for use with tooling"
pretty\:"Display a tree in human-readable form"))' \
'-e[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'--explain[Instead of resolving a rev-spec, explain what would be done for the first spec]' \
'(-e --explain)-r[Also show the name of the reference which led to the object]' \
'(-e --explain)--reference[Also show the name of the reference which led to the object]' \
'(-e --explain)-c[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'(-e --explain)--cat-file[Show the first resulting object similar to how \`git cat-file\` would, but don'\''t show the resolved spec]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::specs -- rev-specs like `@`, `@~1` or `HEAD^2`:_default' \
&& ret=0
;;
(previous-branches)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(prev)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__revision__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-revision-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explain)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(resolve)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(previous-branches)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(credential)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__credential_commands" \
"*::: :->credential" \
&& ret=0

    case $state in
    (credential)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-credential-command-$line[1]:"
        case $line[1] in
            (fill)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(get)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(approve)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(store)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(reject)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(erase)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__credential__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-credential-help-command-$line[1]:"
        case $line[1] in
            (fill)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(approve)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(reject)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(fetch)
_arguments "${_arguments_options[@]}" : \
'-g+[Open the commit graph used for negotiation and write an SVG file to PATH]:PATH:_files' \
'--open-negotiation-graph=[Open the commit graph used for negotiation and write an SVG file to PATH]:PATH:_files' \
'(--shallow-since --shallow-exclude --deepen --unshallow)--depth=[Fetch with the history truncated to the given number of commits as seen from the remote]:DEPTH:_default' \
'(--depth --shallow-since --shallow-exclude --unshallow)--deepen=[Extend the current shallow boundary by the given number of commits, with 0 meaning no change]:DEPTH:_default' \
'(--depth --deepen --unshallow)--shallow-since=[Cutoff all history past the given date. Can be combined with shallow-exclude]:DATE:_default' \
'(--depth --deepen --unshallow)*--shallow-exclude=[Cutoff all history past the tag-name or ref-name. Can be combined with shallow-since]:REF_NAME:_default' \
'-r+[The name of the remote to connect to, or the url of the remote to connect to directly]:REMOTE:_default' \
'--remote=[The name of the remote to connect to, or the url of the remote to connect to directly]:REMOTE:_default' \
'-n[Don'\''t change the local repository, but otherwise try to be as accurate as possible]' \
'--dry-run[Don'\''t change the local repository, but otherwise try to be as accurate as possible]' \
'-H[Output additional typically information provided by the server as part of the connection handshake]' \
'--handshake-info[Output additional typically information provided by the server as part of the connection handshake]' \
'-s[Print statistics about negotiation phase]' \
'--negotiation-info[Print statistics about negotiation phase]' \
'(--shallow-since --shallow-exclude --depth --deepen)--unshallow[Remove the shallow boundary and fetch the entire history available on the remote]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::ref_spec -- Override the built-in and configured ref-specs with one or more of the given ones:_default' \
&& ret=0
;;
(clone)
_arguments "${_arguments_options[@]}" : \
'(--shallow-since --shallow-exclude)--depth=[Create a shallow clone with the history truncated to the given number of commits]:DEPTH:_default' \
'--shallow-since=[Cutoff all history past the given date. Can be combined with shallow-exclude]:DATE:_default' \
'*--shallow-exclude=[Cutoff all history past the tag-name or ref-name. Can be combined with shallow-since]:REF_NAME:_default' \
'--ref=[The name of the reference to check out]:REF_NAME:_default' \
'-H[Output additional typically information provided by the server as part of the connection handshake]' \
'--handshake-info[Output additional typically information provided by the server as part of the connection handshake]' \
'--bare[The clone will be bare and a working tree checkout won'\''t be available]' \
'--no-tags[Do not clone any tags. Useful to reduce the size of the clone if only branches are needed]' \
'-h[Print help]' \
'--help[Print help]' \
':remote -- The url of the remote to connect to, like `https\://github.com/byron/gitoxide`:_default' \
'::directory -- The directory to initialize with the new repository and to which all data should be written:_files' \
&& ret=0
;;
(mailmap)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__mailmap_commands" \
"*::: :->mailmap" \
&& ret=0

    case $state in
    (mailmap)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-mailmap-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(check)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'*::contacts -- One or more `Name <email>` or `<email>` to pass through the mailmap:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__mailmap__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-mailmap-help-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(check)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(remote)
_arguments "${_arguments_options[@]}" : \
'-n+[The name of the remote to connect to, or the URL of the remote to connect to directly]:NAME:_default' \
'--name=[The name of the remote to connect to, or the URL of the remote to connect to directly]:NAME:_default' \
'-H[Output additional typically information provided by the server as part of the connection handshake]' \
'--handshake-info[Output additional typically information provided by the server as part of the connection handshake]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_gix__remote_commands" \
"*::: :->remote" \
&& ret=0

    case $state in
    (remote)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-remote-command-$line[1]:"
        case $line[1] in
            (refs)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(ref-map)
_arguments "${_arguments_options[@]}" : \
'-u[Also display remote references that were sent by the server, but filtered by the refspec locally]' \
'--show-unmapped-remote-refs[Also display remote references that were sent by the server, but filtered by the refspec locally]' \
'-h[Print help]' \
'--help[Print help]' \
'*::ref_spec -- Override the built-in and configured ref-specs with one or more of the given ones:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__remote__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-remote-help-command-$line[1]:"
        case $line[1] in
            (refs)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(ref-map)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(remotes)
_arguments "${_arguments_options[@]}" : \
'-n+[The name of the remote to connect to, or the URL of the remote to connect to directly]:NAME:_default' \
'--name=[The name of the remote to connect to, or the URL of the remote to connect to directly]:NAME:_default' \
'-H[Output additional typically information provided by the server as part of the connection handshake]' \
'--handshake-info[Output additional typically information provided by the server as part of the connection handshake]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
":: :_gix__remote_commands" \
"*::: :->remote" \
&& ret=0

    case $state in
    (remote)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-remote-command-$line[1]:"
        case $line[1] in
            (refs)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(ref-map)
_arguments "${_arguments_options[@]}" : \
'-u[Also display remote references that were sent by the server, but filtered by the refspec locally]' \
'--show-unmapped-remote-refs[Also display remote references that were sent by the server, but filtered by the refspec locally]' \
'-h[Print help]' \
'--help[Print help]' \
'*::ref_spec -- Override the built-in and configured ref-specs with one or more of the given ones:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__remote__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-remote-help-command-$line[1]:"
        case $line[1] in
            (refs)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(ref-map)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(attributes)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__attributes_commands" \
"*::: :->attributes" \
&& ret=0

    case $state in
    (attributes)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-attributes-command-$line[1]:"
        case $line[1] in
            (validate-baseline)
_arguments "${_arguments_options[@]}" : \
'-s[Print various statistics to stderr]' \
'--statistics[Print various statistics to stderr]' \
'--no-ignore[Don'\''t validated excludes as obtaining them with \`check-ignore\` can be very slow]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
'-s[Print various statistics to stderr]' \
'--statistics[Print various statistics to stderr]' \
'-h[Print help]' \
'--help[Print help]' \
'*::pathspec -- The Git path specifications to list attributes for, or unset to read from stdin one per line:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__attributes__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-attributes-help-command-$line[1]:"
        case $line[1] in
            (validate-baseline)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(attrs)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__attributes_commands" \
"*::: :->attributes" \
&& ret=0

    case $state in
    (attributes)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-attributes-command-$line[1]:"
        case $line[1] in
            (validate-baseline)
_arguments "${_arguments_options[@]}" : \
'-s[Print various statistics to stderr]' \
'--statistics[Print various statistics to stderr]' \
'--no-ignore[Don'\''t validated excludes as obtaining them with \`check-ignore\` can be very slow]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
'-s[Print various statistics to stderr]' \
'--statistics[Print various statistics to stderr]' \
'-h[Print help]' \
'--help[Print help]' \
'*::pathspec -- The Git path specifications to list attributes for, or unset to read from stdin one per line:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__attributes__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-attributes-help-command-$line[1]:"
        case $line[1] in
            (validate-baseline)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(exclude)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__exclude_commands" \
"*::: :->exclude" \
&& ret=0

    case $state in
    (exclude)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-exclude-command-$line[1]:"
        case $line[1] in
            (query)
_arguments "${_arguments_options[@]}" : \
'*-p+[Additional patterns to use for exclusions. They have the highest priority]:PATTERNS:_default' \
'*--patterns=[Additional patterns to use for exclusions. They have the highest priority]:PATTERNS:_default' \
'-s[Print various statistics to stderr]' \
'--statistics[Print various statistics to stderr]' \
'-i[Show actual ignore patterns instead of un-excluding an entry]' \
'--show-ignore-patterns[Show actual ignore patterns instead of un-excluding an entry]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::pathspec -- The git path specifications to check for exclusion, or unset to read from stdin one per line:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__exclude__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-exclude-help-command-$line[1]:"
        case $line[1] in
            (query)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(index)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
'-f+[How to output index entries]:FORMAT:((simple\:"Show only minimal information, useful for first glances"
rich\:"Show much more information that is still human-readable"))' \
'--format=[How to output index entries]:FORMAT:((simple\:"Show only minimal information, useful for first glances"
rich\:"Show much more information that is still human-readable"))' \
'--no-attributes[Do not visualize excluded entries or attributes per path]' \
'(--no-attributes)-i[Load attribute and ignore files from the index, don'\''t look at the worktree]' \
'(--no-attributes)--attributes-from-index[Load attribute and ignore files from the index, don'\''t look at the worktree]' \
'-r[Display submodule entries as well if their repository exists]' \
'--recurse-submodules[Display submodule entries as well if their repository exists]' \
'-s[Print various statistics to stderr]' \
'--statistics[Print various statistics to stderr]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::pathspec -- The git path specifications to match entries to print:_default' \
&& ret=0
;;
(from-tree)
_arguments "${_arguments_options[@]}" : \
'-i+[Path to the index file to be written]:INDEX_OUTPUT_PATH:_files' \
'--index-output-path=[Path to the index file to be written]:INDEX_OUTPUT_PATH:_files' \
'-f[Overwrite the specified index file if it already exists]' \
'--force[Overwrite the specified index file if it already exists]' \
'-s[Don'\''t write the trailing hash for a performance gain]' \
'--skip-hash[Don'\''t write the trailing hash for a performance gain]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':spec -- A revspec that points to the to generate the index from:_default' \
&& ret=0
;;
(read-tree)
_arguments "${_arguments_options[@]}" : \
'-i+[Path to the index file to be written]:INDEX_OUTPUT_PATH:_files' \
'--index-output-path=[Path to the index file to be written]:INDEX_OUTPUT_PATH:_files' \
'-f[Overwrite the specified index file if it already exists]' \
'--force[Overwrite the specified index file if it already exists]' \
'-s[Don'\''t write the trailing hash for a performance gain]' \
'--skip-hash[Don'\''t write the trailing hash for a performance gain]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':spec -- A revspec that points to the to generate the index from:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__index__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-index-help-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(from-tree)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(submodule)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__submodule_commands" \
"*::: :->submodule" \
&& ret=0

    case $state in
    (submodule)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-submodule-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-d+[Set the suffix to append if the repository is dirty (not counting untracked files)]' \
'--dirty-suffix=[Set the suffix to append if the repository is dirty (not counting untracked files)]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__submodule__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-submodule-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(cat)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':revspec -- The object to print to stdout:_default' \
&& ret=0
;;
(is-clean)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(is-changed)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(config-tree)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(status)
_arguments "${_arguments_options[@]}" : \
'-f+[The way status data is displayed]:FORMAT:((simplified\:"A basic format that is easy to read, and useful for a first glimpse as flat list"
porcelain-v2\:"Output very similar to \`git status --porcelain=2\`"))' \
'--format=[The way status data is displayed]:FORMAT:((simplified\:"A basic format that is easy to read, and useful for a first glimpse as flat list"
porcelain-v2\:"Output very similar to \`git status --porcelain=2\`"))' \
'--ignored=[If enabled, show ignored files and directories]' \
'--submodules=[Define how to display the submodule status. Defaults to git configuration if unset]:SUBMODULES:((all\:"display all information about submodules, including ref changes, modifications and untracked files"
ref-change\:"Compare only the configuration of the superprojects commit with the actually checked out \`HEAD\` commit"
modifications\:"See if there are worktree modifications compared to the index, but do not check for untracked files"
none\:"Ignore all submodule changes"))' \
'--index-worktree-renames=[Enable rename tracking between the index and the working tree, preventing the collapse of folders as well]' \
'-s[Print additional statistics to help understanding performance]' \
'--statistics[Print additional statistics to help understanding performance]' \
'--no-write[Don'\''t write back a changed index, which forces this operation to always be idempotent]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::pathspec -- The git path specifications to list attributes for, or unset to read from stdin one per line:_default' \
&& ret=0
;;
(config)
_arguments "${_arguments_options[@]}" : \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::filter -- The filter terms to limit the output to matching sections and subsections only:_default' \
&& ret=0
;;
(merge-base)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':first -- A revspec for the first commit:_default' \
'*::others -- Revspecs for the other commits to compute the merge-base with:_default' \
&& ret=0
;;
(merge)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__merge_commands" \
"*::: :->merge" \
&& ret=0

    case $state in
    (merge)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-merge-command-$line[1]:"
        case $line[1] in
            (file)
_arguments "${_arguments_options[@]}" : \
'-c+[Decide how to resolve conflicts. If unset, write conflict markers and fail]:RESOLVE_WITH:((union\:"Use ours then theirs in case of conflict"
ours\:"Use only ours in case of conflict"
theirs\:"Use only theirs in case of conflict"))' \
'--resolve-with=[Decide how to resolve conflicts. If unset, write conflict markers and fail]:RESOLVE_WITH:((union\:"Use ours then theirs in case of conflict"
ours\:"Use only ours in case of conflict"
theirs\:"Use only theirs in case of conflict"))' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':ours -- A path or revspec to our file:_default' \
':base -- A path or revspec to the base for both ours and theirs:_default' \
':theirs -- A path or revspec to their file:_default' \
&& ret=0
;;
(tree)
_arguments "${_arguments_options[@]}" : \
'-f+[Decide how to resolve content conflicts in files. If unset, write conflict markers and fail]:FILE_FAVOR:((ours\:"Use only ours in case of conflict"
theirs\:"Use only theirs in case of conflict"))' \
'--file-favor=[Decide how to resolve content conflicts in files. If unset, write conflict markers and fail]:FILE_FAVOR:((ours\:"Use only ours in case of conflict"
theirs\:"Use only theirs in case of conflict"))' \
'-t+[Decide how to resolve conflicts in trees, i.e. modification/deletion. If unset, try to preserve both states and fail]:TREE_FAVOR:((ancestor\:"Use only the previous tree entry in case of conflict"
ours\:"Use only ours tree entry in case of conflict"))' \
'--tree-favor=[Decide how to resolve conflicts in trees, i.e. modification/deletion. If unset, try to preserve both states and fail]:TREE_FAVOR:((ancestor\:"Use only the previous tree entry in case of conflict"
ours\:"Use only ours tree entry in case of conflict"))' \
'-m[Keep all objects to be written in memory to avoid any disk IO]' \
'--in-memory[Keep all objects to be written in memory to avoid any disk IO]' \
'-d[Print additional information about conflicts for debugging]' \
'--debug[Print additional information about conflicts for debugging]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':ours -- A revspec to our treeish:_default' \
':base -- A revspec to the base as treeish for both ours and theirs:_default' \
':theirs -- A revspec to their treeish:_default' \
&& ret=0
;;
(commit)
_arguments "${_arguments_options[@]}" : \
'-f+[Decide how to resolve content conflicts in files. If unset, write conflict markers and fail]:FILE_FAVOR:((ours\:"Use only ours in case of conflict"
theirs\:"Use only theirs in case of conflict"))' \
'--file-favor=[Decide how to resolve content conflicts in files. If unset, write conflict markers and fail]:FILE_FAVOR:((ours\:"Use only ours in case of conflict"
theirs\:"Use only theirs in case of conflict"))' \
'-t+[Decide how to resolve conflicts in trees, i.e. modification/deletion. If unset, try to preserve both states and fail]:TREE_FAVOR:((ancestor\:"Use only the previous tree entry in case of conflict"
ours\:"Use only ours tree entry in case of conflict"))' \
'--tree-favor=[Decide how to resolve conflicts in trees, i.e. modification/deletion. If unset, try to preserve both states and fail]:TREE_FAVOR:((ancestor\:"Use only the previous tree entry in case of conflict"
ours\:"Use only ours tree entry in case of conflict"))' \
'-m[Keep all objects to be written in memory to avoid any disk IO]' \
'--in-memory[Keep all objects to be written in memory to avoid any disk IO]' \
'-d[Print additional information about conflicts for debugging]' \
'--debug[Print additional information about conflicts for debugging]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':ours -- A revspec to our committish:_default' \
':theirs -- A revspec to their committish:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__merge__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-merge-help-command-$line[1]:"
        case $line[1] in
            (file)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(tree)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(commit)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(env)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(diff)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__diff_commands" \
"*::: :->diff" \
&& ret=0

    case $state in
    (diff)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-diff-command-$line[1]:"
        case $line[1] in
            (tree)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':old_treeish -- A rev-spec representing the '\''before'\'' or old tree:_default' \
':new_treeish -- A rev-spec representing the '\''after'\'' or new tree:_default' \
&& ret=0
;;
(file)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
':old_revspec -- A rev-spec representing the '\''before'\'' or old state of the file, like '\''@~100\:file'\'':_default' \
':new_revspec -- A rev-spec representing the '\''after'\'' or new state of the file, like '\''\:file'\'':_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__diff__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-diff-help-command-$line[1]:"
        case $line[1] in
            (tree)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(file)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(log)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
'::pathspec -- The git path specification to show a log for:_default' \
&& ret=0
;;
(worktree)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__worktree_commands" \
"*::: :->worktree" \
&& ret=0

    case $state in
    (worktree)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-worktree-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__worktree__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-worktree-help-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(free)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free_commands" \
"*::: :->free" \
&& ret=0

    case $state in
    (free)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-command-$line[1]:"
        case $line[1] in
            (commit-graph)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__commit-graph_commands" \
"*::: :->commit-graph" \
&& ret=0

    case $state in
    (commit-graph)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-commit-graph-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
'-s[output statistical information about the pack]' \
'--statistics[output statistical information about the pack]' \
'-h[Print help]' \
'--help[Print help]' \
':path -- The path to '\''.git/objects/info/'\'', '\''.git/objects/info/commit-graphs/'\'', or '\''.git/objects/info/commit-graph'\'' to validate:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__commit-graph__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-commit-graph-help-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(mailmap)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the mailmap file]:PATH:_files' \
'--path=[The path to the mailmap file]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__mailmap_commands" \
"*::: :->mailmap" \
&& ret=0

    case $state in
    (mailmap)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-mailmap-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__mailmap__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-mailmap-help-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(pack)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__pack_commands" \
"*::: :->pack" \
&& ret=0

    case $state in
    (pack)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-command-$line[1]:"
        case $line[1] in
            (index)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__pack__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-index-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
'-i+[Specify how to iterate the pack, defaults to '\''verify'\'']:ITERATION_MODE:(as-is verify restore)' \
'--iteration-mode=[Specify how to iterate the pack, defaults to '\''verify'\'']:ITERATION_MODE:(as-is verify restore)' \
'-p+[Path to the pack file to read (with .pack extension)]:PACK_PATH:_files' \
'--pack-path=[Path to the pack file to read (with .pack extension)]:PACK_PATH:_files' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'::directory -- The folder into which to place the pack and the generated index file:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__index__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-index-help-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(multi-index)
_arguments "${_arguments_options[@]}" : \
'-i+[The path to the index file]:MULTI_INDEX_PATH:_files' \
'--multi-index-path=[The path to the index file]:MULTI_INDEX_PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__pack__multi-index_commands" \
"*::: :->multi-index" \
&& ret=0

    case $state in
    (multi-index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-multi-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::index_paths -- Paths to the pack index files to read (with .idx extension):_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__multi-index__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-multi-index-help-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-r+[the directory containing the '\''.git'\'' repository from which objects should be read]:REPOSITORY:_files' \
'--repository=[the directory containing the '\''.git'\'' repository from which objects should be read]:REPOSITORY:_files' \
'-e+[the way objects are expanded. They differ in costs]:EXPANSION:(none tree-traversal tree-diff)' \
'--expansion=[the way objects are expanded. They differ in costs]:EXPANSION:(none tree-traversal tree-diff)' \
'--counting-threads=[The amount of threads to use when counting and the \`--nondeterminisitc-count\` flag is set, defaulting to the globally configured threads]:COUNTING_THREADS:_default' \
'--pack-cache-size-mb=[The size in megabytes for a cache to speed up pack access for packs with long delta chains. It is shared among all threads, so 4 threads would use their own cache 1/4th of the size]:PACK_CACHE_SIZE_MB:_default' \
'--object-cache-size-mb=[The size in megabytes for a cache to speed up accessing entire objects, bypassing object database access when hit. It is shared among all threads, so 4 threads would use their own cache 1/4th of the size]:OBJECT_CACHE_SIZE_MB:_default' \
'-o+[The directory into which to write the pack file]:OUTPUT_DIRECTORY:_files' \
'--output-directory=[The directory into which to write the pack file]:OUTPUT_DIRECTORY:_files' \
'--nondeterministic-count[if set, the counting phase may be accelerated using multithreading]' \
'-s[If set statistical information will be presented to inform about pack creation details. It'\''s a form of instrumentation for developers to help improve pack generation]' \
'--statistics[If set statistical information will be presented to inform about pack creation details. It'\''s a form of instrumentation for developers to help improve pack generation]' \
'--thin[if set, delta-objects whose base object wouldn'\''t be in the pack will not be recompressed as base object, but instead refer to its base object using its object id]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::tips -- The tips from which to start the commit graph iteration, either as fully qualified commit hashes or as branch names:_default' \
&& ret=0
;;
(receive)
_arguments "${_arguments_options[@]}" : \
'-p+[The protocol version to use. Valid values are 1 and 2]:PROTOCOL:_default' \
'--protocol=[The protocol version to use. Valid values are 1 and 2]:PROTOCOL:_default' \
'-d+[the directory into which to write references. Existing files will be overwritten]:REFS_DIRECTORY:_files' \
'--refs-directory=[the directory into which to write references. Existing files will be overwritten]:REFS_DIRECTORY:_files' \
'*-r+[If set once or more times, these references will be fetched instead of all advertised ones]:REFS:_default' \
'*--reference=[If set once or more times, these references will be fetched instead of all advertised ones]:REFS:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':url -- The URLs or path from which to receive the pack:_default' \
'::directory -- The directory into which to write the received pack and index:_files' \
&& ret=0
;;
(explode)
_arguments "${_arguments_options[@]}" : \
'-c+[The amount of checks to run]:CHECK:(all skip-file-checksum skip-file-and-object-checksum skip-file-and-object-checksum-and-no-abort-on-decode)' \
'--check=[The amount of checks to run]:CHECK:(all skip-file-checksum skip-file-and-object-checksum skip-file-and-object-checksum-and-no-abort-on-decode)' \
'--verify[Read written objects back and assert they match their source. Fail the operation otherwise]' \
'--delete-pack[delete the pack and index file after the operation is successful]' \
'--sink-compress[Compress bytes even when using the sink, i.e. no object directory is specified]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':pack_path -- The '\''.pack'\'' or '\''.idx'\'' file to explode into loose objects:_files' \
'::object_path -- The path into which all objects should be written. Commonly '\''.git/objects'\'':_files' \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'-a+[The algorithm used to verify packs. They differ in costs]:ALGORITHM:(less-time less-memory)' \
'--algorithm=[The algorithm used to verify packs. They differ in costs]:ALGORITHM:(less-time less-memory)' \
'-s[output statistical information]' \
'--statistics[output statistical information]' \
'(--re-encode)--decode[Decode and parse tags, commits and trees to validate their correctness beyond hashing correctly]' \
'--re-encode[Decode and parse tags, commits and trees to validate their correctness, and re-encode them]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':path -- The '\''.pack'\'', '\''.idx'\'' or '\''multi-pack-index'\'' file to validate:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-help-command-$line[1]:"
        case $line[1] in
            (index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__help__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-help-index-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(multi-index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__help__multi-index_commands" \
"*::: :->multi-index" \
&& ret=0

    case $state in
    (multi-index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-help-multi-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(receive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explode)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(index)
_arguments "${_arguments_options[@]}" : \
'--object-hash=[The object format to assume when reading files that don'\''t inherently know about it, or when writing files]:OBJECT_HASH:(SHA1)' \
'-i+[The path to the index file]:INDEX_PATH:_files' \
'--index-path=[The path to the index file]:INDEX_PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-index-command-$line[1]:"
        case $line[1] in
            (from-list)
_arguments "${_arguments_options[@]}" : \
'-i+[Path to the index file to be written. If none is given it will be kept in memory only as a way to measure performance. One day we will probably write the index back by default, but that requires us to write more of the index to work]:INDEX_OUTPUT_PATH:_files' \
'--index-output-path=[Path to the index file to be written. If none is given it will be kept in memory only as a way to measure performance. One day we will probably write the index back by default, but that requires us to write more of the index to work]:INDEX_OUTPUT_PATH:_files' \
'-f[Overwrite the specified index file if it already exists]' \
'--force[Overwrite the specified index file if it already exists]' \
'-s[Don'\''t write the trailing hash for a performance gain]' \
'--skip-hash[Don'\''t write the trailing hash for a performance gain]' \
'-h[Print help]' \
'--help[Print help]' \
':file -- The file to read the index entries from, one path per line:_files' \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
'--no-details[Do not extract specific extension information to gain only a superficial idea of the index'\''s composition]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(checkout-exclusive)
_arguments "${_arguments_options[@]}" : \
'-r+[The path to \`.git\` repository from which objects can be obtained to write the actual files referenced in the index. Use this measure the impact on extracting objects on overall performance]:REPOSITORY:_files' \
'--repository=[The path to \`.git\` repository from which objects can be obtained to write the actual files referenced in the index. Use this measure the impact on extracting objects on overall performance]:REPOSITORY:_files' \
'-k[Ignore errors and keep checking out as many files as possible, and report all errors at the end of the operation]' \
'--keep-going[Ignore errors and keep checking out as many files as possible, and report all errors at the end of the operation]' \
'-e[Enable to query the object database yet write only empty files. This is useful to measure the overhead of ODB query compared to writing the bytes to disk]' \
'--empty-files[Enable to query the object database yet write only empty files. This is useful to measure the overhead of ODB query compared to writing the bytes to disk]' \
'-h[Print help]' \
'--help[Print help]' \
':directory -- The directory into which to write all index entries:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__index__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-index-help-command-$line[1]:"
        case $line[1] in
            (from-list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(checkout-exclusive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(discover)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-command-$line[1]:"
        case $line[1] in
            (commit-graph)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__commit-graph_commands" \
"*::: :->commit-graph" \
&& ret=0

    case $state in
    (commit-graph)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-commit-graph-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(mailmap)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__mailmap_commands" \
"*::: :->mailmap" \
&& ret=0

    case $state in
    (mailmap)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-mailmap-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(pack)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__pack_commands" \
"*::: :->pack" \
&& ret=0

    case $state in
    (pack)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-pack-command-$line[1]:"
        case $line[1] in
            (index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__pack__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-pack-index-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(multi-index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__pack__multi-index_commands" \
"*::: :->multi-index" \
&& ret=0

    case $state in
    (multi-index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-pack-multi-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(receive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explode)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-index-command-$line[1]:"
        case $line[1] in
            (from-list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(checkout-exclusive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(discover)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(no-repo)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free_commands" \
"*::: :->free" \
&& ret=0

    case $state in
    (free)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-command-$line[1]:"
        case $line[1] in
            (commit-graph)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__commit-graph_commands" \
"*::: :->commit-graph" \
&& ret=0

    case $state in
    (commit-graph)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-commit-graph-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
'-s[output statistical information about the pack]' \
'--statistics[output statistical information about the pack]' \
'-h[Print help]' \
'--help[Print help]' \
':path -- The path to '\''.git/objects/info/'\'', '\''.git/objects/info/commit-graphs/'\'', or '\''.git/objects/info/commit-graph'\'' to validate:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__commit-graph__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-commit-graph-help-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(mailmap)
_arguments "${_arguments_options[@]}" : \
'-p+[The path to the mailmap file]:PATH:_files' \
'--path=[The path to the mailmap file]:PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__mailmap_commands" \
"*::: :->mailmap" \
&& ret=0

    case $state in
    (mailmap)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-mailmap-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__mailmap__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-mailmap-help-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(pack)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__pack_commands" \
"*::: :->pack" \
&& ret=0

    case $state in
    (pack)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-command-$line[1]:"
        case $line[1] in
            (index)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__pack__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-index-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
'-i+[Specify how to iterate the pack, defaults to '\''verify'\'']:ITERATION_MODE:(as-is verify restore)' \
'--iteration-mode=[Specify how to iterate the pack, defaults to '\''verify'\'']:ITERATION_MODE:(as-is verify restore)' \
'-p+[Path to the pack file to read (with .pack extension)]:PACK_PATH:_files' \
'--pack-path=[Path to the pack file to read (with .pack extension)]:PACK_PATH:_files' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'::directory -- The folder into which to place the pack and the generated index file:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__index__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-index-help-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(multi-index)
_arguments "${_arguments_options[@]}" : \
'-i+[The path to the index file]:MULTI_INDEX_PATH:_files' \
'--multi-index-path=[The path to the index file]:MULTI_INDEX_PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__pack__multi-index_commands" \
"*::: :->multi-index" \
&& ret=0

    case $state in
    (multi-index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-multi-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::index_paths -- Paths to the pack index files to read (with .idx extension):_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__multi-index__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-multi-index-help-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(create)
_arguments "${_arguments_options[@]}" : \
'-r+[the directory containing the '\''.git'\'' repository from which objects should be read]:REPOSITORY:_files' \
'--repository=[the directory containing the '\''.git'\'' repository from which objects should be read]:REPOSITORY:_files' \
'-e+[the way objects are expanded. They differ in costs]:EXPANSION:(none tree-traversal tree-diff)' \
'--expansion=[the way objects are expanded. They differ in costs]:EXPANSION:(none tree-traversal tree-diff)' \
'--counting-threads=[The amount of threads to use when counting and the \`--nondeterminisitc-count\` flag is set, defaulting to the globally configured threads]:COUNTING_THREADS:_default' \
'--pack-cache-size-mb=[The size in megabytes for a cache to speed up pack access for packs with long delta chains. It is shared among all threads, so 4 threads would use their own cache 1/4th of the size]:PACK_CACHE_SIZE_MB:_default' \
'--object-cache-size-mb=[The size in megabytes for a cache to speed up accessing entire objects, bypassing object database access when hit. It is shared among all threads, so 4 threads would use their own cache 1/4th of the size]:OBJECT_CACHE_SIZE_MB:_default' \
'-o+[The directory into which to write the pack file]:OUTPUT_DIRECTORY:_files' \
'--output-directory=[The directory into which to write the pack file]:OUTPUT_DIRECTORY:_files' \
'--nondeterministic-count[if set, the counting phase may be accelerated using multithreading]' \
'-s[If set statistical information will be presented to inform about pack creation details. It'\''s a form of instrumentation for developers to help improve pack generation]' \
'--statistics[If set statistical information will be presented to inform about pack creation details. It'\''s a form of instrumentation for developers to help improve pack generation]' \
'--thin[if set, delta-objects whose base object wouldn'\''t be in the pack will not be recompressed as base object, but instead refer to its base object using its object id]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
'*::tips -- The tips from which to start the commit graph iteration, either as fully qualified commit hashes or as branch names:_default' \
&& ret=0
;;
(receive)
_arguments "${_arguments_options[@]}" : \
'-p+[The protocol version to use. Valid values are 1 and 2]:PROTOCOL:_default' \
'--protocol=[The protocol version to use. Valid values are 1 and 2]:PROTOCOL:_default' \
'-d+[the directory into which to write references. Existing files will be overwritten]:REFS_DIRECTORY:_files' \
'--refs-directory=[the directory into which to write references. Existing files will be overwritten]:REFS_DIRECTORY:_files' \
'*-r+[If set once or more times, these references will be fetched instead of all advertised ones]:REFS:_default' \
'*--reference=[If set once or more times, these references will be fetched instead of all advertised ones]:REFS:_default' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':url -- The URLs or path from which to receive the pack:_default' \
'::directory -- The directory into which to write the received pack and index:_files' \
&& ret=0
;;
(explode)
_arguments "${_arguments_options[@]}" : \
'-c+[The amount of checks to run]:CHECK:(all skip-file-checksum skip-file-and-object-checksum skip-file-and-object-checksum-and-no-abort-on-decode)' \
'--check=[The amount of checks to run]:CHECK:(all skip-file-checksum skip-file-and-object-checksum skip-file-and-object-checksum-and-no-abort-on-decode)' \
'--verify[Read written objects back and assert they match their source. Fail the operation otherwise]' \
'--delete-pack[delete the pack and index file after the operation is successful]' \
'--sink-compress[Compress bytes even when using the sink, i.e. no object directory is specified]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':pack_path -- The '\''.pack'\'' or '\''.idx'\'' file to explode into loose objects:_files' \
'::object_path -- The path into which all objects should be written. Commonly '\''.git/objects'\'':_files' \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'-a+[The algorithm used to verify packs. They differ in costs]:ALGORITHM:(less-time less-memory)' \
'--algorithm=[The algorithm used to verify packs. They differ in costs]:ALGORITHM:(less-time less-memory)' \
'-s[output statistical information]' \
'--statistics[output statistical information]' \
'(--re-encode)--decode[Decode and parse tags, commits and trees to validate their correctness beyond hashing correctly]' \
'--re-encode[Decode and parse tags, commits and trees to validate their correctness, and re-encode them]' \
'-h[Print help (see more with '\''--help'\'')]' \
'--help[Print help (see more with '\''--help'\'')]' \
':path -- The '\''.pack'\'', '\''.idx'\'' or '\''multi-pack-index'\'' file to validate:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-help-command-$line[1]:"
        case $line[1] in
            (index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__help__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-help-index-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(multi-index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__pack__help__multi-index_commands" \
"*::: :->multi-index" \
&& ret=0

    case $state in
    (multi-index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-pack-help-multi-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(receive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explode)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(index)
_arguments "${_arguments_options[@]}" : \
'--object-hash=[The object format to assume when reading files that don'\''t inherently know about it, or when writing files]:OBJECT_HASH:(SHA1)' \
'-i+[The path to the index file]:INDEX_PATH:_files' \
'--index-path=[The path to the index file]:INDEX_PATH:_files' \
'-h[Print help]' \
'--help[Print help]' \
":: :_gix__free__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-index-command-$line[1]:"
        case $line[1] in
            (from-list)
_arguments "${_arguments_options[@]}" : \
'-i+[Path to the index file to be written. If none is given it will be kept in memory only as a way to measure performance. One day we will probably write the index back by default, but that requires us to write more of the index to work]:INDEX_OUTPUT_PATH:_files' \
'--index-output-path=[Path to the index file to be written. If none is given it will be kept in memory only as a way to measure performance. One day we will probably write the index back by default, but that requires us to write more of the index to work]:INDEX_OUTPUT_PATH:_files' \
'-f[Overwrite the specified index file if it already exists]' \
'--force[Overwrite the specified index file if it already exists]' \
'-s[Don'\''t write the trailing hash for a performance gain]' \
'--skip-hash[Don'\''t write the trailing hash for a performance gain]' \
'-h[Print help]' \
'--help[Print help]' \
':file -- The file to read the index entries from, one path per line:_files' \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
'--no-details[Do not extract specific extension information to gain only a superficial idea of the index'\''s composition]' \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(checkout-exclusive)
_arguments "${_arguments_options[@]}" : \
'-r+[The path to \`.git\` repository from which objects can be obtained to write the actual files referenced in the index. Use this measure the impact on extracting objects on overall performance]:REPOSITORY:_files' \
'--repository=[The path to \`.git\` repository from which objects can be obtained to write the actual files referenced in the index. Use this measure the impact on extracting objects on overall performance]:REPOSITORY:_files' \
'-k[Ignore errors and keep checking out as many files as possible, and report all errors at the end of the operation]' \
'--keep-going[Ignore errors and keep checking out as many files as possible, and report all errors at the end of the operation]' \
'-e[Enable to query the object database yet write only empty files. This is useful to measure the overhead of ODB query compared to writing the bytes to disk]' \
'--empty-files[Enable to query the object database yet write only empty files. This is useful to measure the overhead of ODB query compared to writing the bytes to disk]' \
'-h[Print help]' \
'--help[Print help]' \
':directory -- The directory into which to write all index entries:_files' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__index__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-index-help-command-$line[1]:"
        case $line[1] in
            (from-list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(checkout-exclusive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(discover)
_arguments "${_arguments_options[@]}" : \
'-h[Print help]' \
'--help[Print help]' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-command-$line[1]:"
        case $line[1] in
            (commit-graph)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__commit-graph_commands" \
"*::: :->commit-graph" \
&& ret=0

    case $state in
    (commit-graph)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-commit-graph-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(mailmap)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__mailmap_commands" \
"*::: :->mailmap" \
&& ret=0

    case $state in
    (mailmap)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-mailmap-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(pack)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__pack_commands" \
"*::: :->pack" \
&& ret=0

    case $state in
    (pack)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-pack-command-$line[1]:"
        case $line[1] in
            (index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__pack__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-pack-index-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(multi-index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__pack__multi-index_commands" \
"*::: :->multi-index" \
&& ret=0

    case $state in
    (multi-index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-pack-multi-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(receive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explode)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__free__help__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-free-help-index-command-$line[1]:"
        case $line[1] in
            (from-list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(checkout-exclusive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(discover)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
;;
(blame)
_arguments "${_arguments_options[@]}" : \
'*-L+[Only blame lines in the given 1-based inclusive range '\''<start>,<end>'\'', e.g. '\''20,40'\'']:RANGES:_default' \
'--since=[Don'\''t consider commits before the given date]:DATE:_default' \
'-s[Print additional statistics to help understanding performance]' \
'--statistics[Print additional statistics to help understanding performance]' \
'-h[Print help]' \
'--help[Print help]' \
':file -- The file to create the blame information for:_default' \
&& ret=0
;;
(completions)
_arguments "${_arguments_options[@]}" : \
'-s+[The shell to generate completions for. Otherwise it'\''s derived from the environment]:SHELL:(bash elvish fish powershell zsh)' \
'--shell=[The shell to generate completions for. Otherwise it'\''s derived from the environment]:SHELL:(bash elvish fish powershell zsh)' \
'-h[Print help]' \
'--help[Print help]' \
'::out_dir -- The output directory in case multiple files are generated. If not provided, will write to stdout:_default' \
&& ret=0
;;
(generate-completions)
_arguments "${_arguments_options[@]}" : \
'-s+[The shell to generate completions for. Otherwise it'\''s derived from the environment]:SHELL:(bash elvish fish powershell zsh)' \
'--shell=[The shell to generate completions for. Otherwise it'\''s derived from the environment]:SHELL:(bash elvish fish powershell zsh)' \
'-h[Print help]' \
'--help[Print help]' \
'::out_dir -- The output directory in case multiple files are generated. If not provided, will write to stdout:_default' \
&& ret=0
;;
(shell-completions)
_arguments "${_arguments_options[@]}" : \
'-s+[The shell to generate completions for. Otherwise it'\''s derived from the environment]:SHELL:(bash elvish fish powershell zsh)' \
'--shell=[The shell to generate completions for. Otherwise it'\''s derived from the environment]:SHELL:(bash elvish fish powershell zsh)' \
'-h[Print help]' \
'--help[Print help]' \
'::out_dir -- The output directory in case multiple files are generated. If not provided, will write to stdout:_default' \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help_commands" \
"*::: :->help" \
&& ret=0

    case $state in
    (help)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-command-$line[1]:"
        case $line[1] in
            (archive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(clean)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(commit-graph)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__commit-graph_commands" \
"*::: :->commit-graph" \
&& ret=0

    case $state in
    (commit-graph)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-commit-graph-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(odb)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__odb_commands" \
"*::: :->odb" \
&& ret=0

    case $state in
    (odb)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-odb-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(stats)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(fsck)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(tree)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__tree_commands" \
"*::: :->tree" \
&& ret=0

    case $state in
    (tree)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-tree-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(commit)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__commit_commands" \
"*::: :->commit" \
&& ret=0

    case $state in
    (commit)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-commit-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(describe)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(tag)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__tag_commands" \
"*::: :->tag" \
&& ret=0

    case $state in
    (tag)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-tag-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(revision)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__revision_commands" \
"*::: :->revision" \
&& ret=0

    case $state in
    (revision)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-revision-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explain)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(resolve)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(previous-branches)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(credential)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__credential_commands" \
"*::: :->credential" \
&& ret=0

    case $state in
    (credential)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-credential-command-$line[1]:"
        case $line[1] in
            (fill)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(approve)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(reject)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(fetch)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(clone)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(mailmap)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__mailmap_commands" \
"*::: :->mailmap" \
&& ret=0

    case $state in
    (mailmap)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-mailmap-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(check)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(remote)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__remote_commands" \
"*::: :->remote" \
&& ret=0

    case $state in
    (remote)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-remote-command-$line[1]:"
        case $line[1] in
            (refs)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(ref-map)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(attributes)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__attributes_commands" \
"*::: :->attributes" \
&& ret=0

    case $state in
    (attributes)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-attributes-command-$line[1]:"
        case $line[1] in
            (validate-baseline)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(query)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(exclude)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__exclude_commands" \
"*::: :->exclude" \
&& ret=0

    case $state in
    (exclude)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-exclude-command-$line[1]:"
        case $line[1] in
            (query)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(from-tree)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(submodule)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__submodule_commands" \
"*::: :->submodule" \
&& ret=0

    case $state in
    (submodule)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-submodule-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(cat)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(is-clean)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(is-changed)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(config-tree)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(status)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(config)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(merge-base)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(merge)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__merge_commands" \
"*::: :->merge" \
&& ret=0

    case $state in
    (merge)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-merge-command-$line[1]:"
        case $line[1] in
            (file)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(tree)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(commit)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(env)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(diff)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__diff_commands" \
"*::: :->diff" \
&& ret=0

    case $state in
    (diff)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-diff-command-$line[1]:"
        case $line[1] in
            (tree)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(file)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(log)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(worktree)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__worktree_commands" \
"*::: :->worktree" \
&& ret=0

    case $state in
    (worktree)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-worktree-command-$line[1]:"
        case $line[1] in
            (list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(free)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__free_commands" \
"*::: :->free" \
&& ret=0

    case $state in
    (free)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-free-command-$line[1]:"
        case $line[1] in
            (commit-graph)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__free__commit-graph_commands" \
"*::: :->commit-graph" \
&& ret=0

    case $state in
    (commit-graph)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-free-commit-graph-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(mailmap)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__free__mailmap_commands" \
"*::: :->mailmap" \
&& ret=0

    case $state in
    (mailmap)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-free-mailmap-command-$line[1]:"
        case $line[1] in
            (verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(pack)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__free__pack_commands" \
"*::: :->pack" \
&& ret=0

    case $state in
    (pack)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-free-pack-command-$line[1]:"
        case $line[1] in
            (index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__free__pack__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-free-pack-index-command-$line[1]:"
        case $line[1] in
            (create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(multi-index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__free__pack__multi-index_commands" \
"*::: :->multi-index" \
&& ret=0

    case $state in
    (multi-index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-free-pack-multi-index-command-$line[1]:"
        case $line[1] in
            (entries)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(create)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(receive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(explode)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(index)
_arguments "${_arguments_options[@]}" : \
":: :_gix__help__free__index_commands" \
"*::: :->index" \
&& ret=0

    case $state in
    (index)
        words=("$line"[1] "${words[@]}")
        (( CURRENT += 1 ))
        curcontext="${curcontext%:*:*}:gix-help-free-index-command-$line[1]:"
        case $line[1] in
            (from-list)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(verify)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(info)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(checkout-exclusive)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(discover)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
(blame)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(completions)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
(help)
_arguments "${_arguments_options[@]}" : \
&& ret=0
;;
        esac
    ;;
esac
;;
        esac
    ;;
esac
}

(( $+functions[_gix_commands] )) ||
_gix_commands() {
    local commands; commands=(
'archive:Subcommands for creating worktree archives' \
'clean:Remove untracked files from the working tree' \
'commit-graph:Subcommands for interacting with commit-graph files' \
'odb:Interact with the object database' \
'fsck:Check for missing objects' \
'tree:Interact with tree objects' \
'commit:Interact with commit objects' \
'tag:Interact with tag objects' \
'tags:Interact with tag objects' \
'verify:Verify the integrity of the entire repository' \
'revision:Query and obtain information about revisions' \
'rev:Query and obtain information about revisions' \
'r:Query and obtain information about revisions' \
'credential:A program just like \`git credential\`' \
'fetch:Fetch data from remotes and store it in the repository' \
'clone:Clone a repository into a new directory' \
'mailmap:Interact with the mailmap' \
'remote:Interact with the remote hosts' \
'remotes:Interact with the remote hosts' \
'attributes:Interact with the attribute files like .gitattributes' \
'attrs:Interact with the attribute files like .gitattributes' \
'exclude:Interact with the exclude files like .gitignore' \
'index:Interact with a worktree index like .git/index' \
'submodule:Interact with submodules' \
'cat:Show whatever object is at the given spec' \
'is-clean:Check for changes in the repository, treating this as an error' \
'is-changed:Check for changes in the repository, treating their absence as an error' \
'config-tree:Show which git configuration values are used or planned' \
'status:Compute repository status similar to \`git status\`' \
'config:Print all entries in a configuration file or access other sub-commands' \
'merge-base:A command for calculating all merge-bases' \
'merge:Perform merges of various kinds' \
'env:Print paths relevant to the Git installation' \
'diff:Print all changes between two objects' \
'log:List all commits in a repository, optionally limited to those that change a given path' \
'worktree:Commands for handling worktrees' \
'free:Subcommands that need no Git repository to run' \
'no-repo:Subcommands that need no Git repository to run' \
'blame:Blame lines in a file' \
'completions:Generate shell completions to stdout or a directory' \
'generate-completions:Generate shell completions to stdout or a directory' \
'shell-completions:Generate shell completions to stdout or a directory' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix commands' commands "$@"
}
(( $+functions[_gix__archive_commands] )) ||
_gix__archive_commands() {
    local commands; commands=()
    _describe -t commands 'gix archive commands' commands "$@"
}
(( $+functions[_gix__attributes_commands] )) ||
_gix__attributes_commands() {
    local commands; commands=(
'validate-baseline:Run \`git check-attr\` and \`git check-ignore\` on all files of the index or all files passed via stdin and validate that we get the same outcome when computing attributes' \
'query:List all attributes of the given path-specs and display the result similar to \`git check-attr\`' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix attributes commands' commands "$@"
}
(( $+functions[_gix__attributes__help_commands] )) ||
_gix__attributes__help_commands() {
    local commands; commands=(
'validate-baseline:Run \`git check-attr\` and \`git check-ignore\` on all files of the index or all files passed via stdin and validate that we get the same outcome when computing attributes' \
'query:List all attributes of the given path-specs and display the result similar to \`git check-attr\`' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix attributes help commands' commands "$@"
}
(( $+functions[_gix__attributes__help__help_commands] )) ||
_gix__attributes__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix attributes help help commands' commands "$@"
}
(( $+functions[_gix__attributes__help__query_commands] )) ||
_gix__attributes__help__query_commands() {
    local commands; commands=()
    _describe -t commands 'gix attributes help query commands' commands "$@"
}
(( $+functions[_gix__attributes__help__validate-baseline_commands] )) ||
_gix__attributes__help__validate-baseline_commands() {
    local commands; commands=()
    _describe -t commands 'gix attributes help validate-baseline commands' commands "$@"
}
(( $+functions[_gix__attributes__query_commands] )) ||
_gix__attributes__query_commands() {
    local commands; commands=()
    _describe -t commands 'gix attributes query commands' commands "$@"
}
(( $+functions[_gix__attributes__validate-baseline_commands] )) ||
_gix__attributes__validate-baseline_commands() {
    local commands; commands=()
    _describe -t commands 'gix attributes validate-baseline commands' commands "$@"
}
(( $+functions[_gix__blame_commands] )) ||
_gix__blame_commands() {
    local commands; commands=()
    _describe -t commands 'gix blame commands' commands "$@"
}
(( $+functions[_gix__cat_commands] )) ||
_gix__cat_commands() {
    local commands; commands=()
    _describe -t commands 'gix cat commands' commands "$@"
}
(( $+functions[_gix__clean_commands] )) ||
_gix__clean_commands() {
    local commands; commands=()
    _describe -t commands 'gix clean commands' commands "$@"
}
(( $+functions[_gix__clone_commands] )) ||
_gix__clone_commands() {
    local commands; commands=()
    _describe -t commands 'gix clone commands' commands "$@"
}
(( $+functions[_gix__commit_commands] )) ||
_gix__commit_commands() {
    local commands; commands=(
'verify:Verify the signature of a commit' \
'describe:Describe the current commit or the given one using the name of the closest annotated tag in its ancestry' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix commit commands' commands "$@"
}
(( $+functions[_gix__commit__describe_commands] )) ||
_gix__commit__describe_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit describe commands' commands "$@"
}
(( $+functions[_gix__commit__help_commands] )) ||
_gix__commit__help_commands() {
    local commands; commands=(
'verify:Verify the signature of a commit' \
'describe:Describe the current commit or the given one using the name of the closest annotated tag in its ancestry' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix commit help commands' commands "$@"
}
(( $+functions[_gix__commit__help__describe_commands] )) ||
_gix__commit__help__describe_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit help describe commands' commands "$@"
}
(( $+functions[_gix__commit__help__help_commands] )) ||
_gix__commit__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit help help commands' commands "$@"
}
(( $+functions[_gix__commit__help__verify_commands] )) ||
_gix__commit__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit help verify commands' commands "$@"
}
(( $+functions[_gix__commit__verify_commands] )) ||
_gix__commit__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit verify commands' commands "$@"
}
(( $+functions[_gix__commit-graph_commands] )) ||
_gix__commit-graph_commands() {
    local commands; commands=(
'verify:Verify the integrity of a commit graph file' \
'list:List all entries in the commit-graph file as reachable by starting from \`HEAD\`' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix commit-graph commands' commands "$@"
}
(( $+functions[_gix__commit-graph__help_commands] )) ||
_gix__commit-graph__help_commands() {
    local commands; commands=(
'verify:Verify the integrity of a commit graph file' \
'list:List all entries in the commit-graph file as reachable by starting from \`HEAD\`' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix commit-graph help commands' commands "$@"
}
(( $+functions[_gix__commit-graph__help__help_commands] )) ||
_gix__commit-graph__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit-graph help help commands' commands "$@"
}
(( $+functions[_gix__commit-graph__help__list_commands] )) ||
_gix__commit-graph__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit-graph help list commands' commands "$@"
}
(( $+functions[_gix__commit-graph__help__verify_commands] )) ||
_gix__commit-graph__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit-graph help verify commands' commands "$@"
}
(( $+functions[_gix__commit-graph__list_commands] )) ||
_gix__commit-graph__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit-graph list commands' commands "$@"
}
(( $+functions[_gix__commit-graph__verify_commands] )) ||
_gix__commit-graph__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix commit-graph verify commands' commands "$@"
}
(( $+functions[_gix__completions_commands] )) ||
_gix__completions_commands() {
    local commands; commands=()
    _describe -t commands 'gix completions commands' commands "$@"
}
(( $+functions[_gix__config_commands] )) ||
_gix__config_commands() {
    local commands; commands=()
    _describe -t commands 'gix config commands' commands "$@"
}
(( $+functions[_gix__config-tree_commands] )) ||
_gix__config-tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix config-tree commands' commands "$@"
}
(( $+functions[_gix__credential_commands] )) ||
_gix__credential_commands() {
    local commands; commands=(
'fill:Get the credentials fed for \`url=<url>\` via STDIN' \
'get:Get the credentials fed for \`url=<url>\` via STDIN' \
'approve:Approve the information piped via STDIN as obtained with last call to \`fill\`' \
'store:Approve the information piped via STDIN as obtained with last call to \`fill\`' \
'reject:Try to resolve the given revspec and print the object names' \
'erase:Try to resolve the given revspec and print the object names' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix credential commands' commands "$@"
}
(( $+functions[_gix__credential__approve_commands] )) ||
_gix__credential__approve_commands() {
    local commands; commands=()
    _describe -t commands 'gix credential approve commands' commands "$@"
}
(( $+functions[_gix__credential__fill_commands] )) ||
_gix__credential__fill_commands() {
    local commands; commands=()
    _describe -t commands 'gix credential fill commands' commands "$@"
}
(( $+functions[_gix__credential__help_commands] )) ||
_gix__credential__help_commands() {
    local commands; commands=(
'fill:Get the credentials fed for \`url=<url>\` via STDIN' \
'approve:Approve the information piped via STDIN as obtained with last call to \`fill\`' \
'reject:Try to resolve the given revspec and print the object names' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix credential help commands' commands "$@"
}
(( $+functions[_gix__credential__help__approve_commands] )) ||
_gix__credential__help__approve_commands() {
    local commands; commands=()
    _describe -t commands 'gix credential help approve commands' commands "$@"
}
(( $+functions[_gix__credential__help__fill_commands] )) ||
_gix__credential__help__fill_commands() {
    local commands; commands=()
    _describe -t commands 'gix credential help fill commands' commands "$@"
}
(( $+functions[_gix__credential__help__help_commands] )) ||
_gix__credential__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix credential help help commands' commands "$@"
}
(( $+functions[_gix__credential__help__reject_commands] )) ||
_gix__credential__help__reject_commands() {
    local commands; commands=()
    _describe -t commands 'gix credential help reject commands' commands "$@"
}
(( $+functions[_gix__credential__reject_commands] )) ||
_gix__credential__reject_commands() {
    local commands; commands=()
    _describe -t commands 'gix credential reject commands' commands "$@"
}
(( $+functions[_gix__diff_commands] )) ||
_gix__diff_commands() {
    local commands; commands=(
'tree:Diff two trees' \
'file:Diff two versions of a file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix diff commands' commands "$@"
}
(( $+functions[_gix__diff__file_commands] )) ||
_gix__diff__file_commands() {
    local commands; commands=()
    _describe -t commands 'gix diff file commands' commands "$@"
}
(( $+functions[_gix__diff__help_commands] )) ||
_gix__diff__help_commands() {
    local commands; commands=(
'tree:Diff two trees' \
'file:Diff two versions of a file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix diff help commands' commands "$@"
}
(( $+functions[_gix__diff__help__file_commands] )) ||
_gix__diff__help__file_commands() {
    local commands; commands=()
    _describe -t commands 'gix diff help file commands' commands "$@"
}
(( $+functions[_gix__diff__help__help_commands] )) ||
_gix__diff__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix diff help help commands' commands "$@"
}
(( $+functions[_gix__diff__help__tree_commands] )) ||
_gix__diff__help__tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix diff help tree commands' commands "$@"
}
(( $+functions[_gix__diff__tree_commands] )) ||
_gix__diff__tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix diff tree commands' commands "$@"
}
(( $+functions[_gix__env_commands] )) ||
_gix__env_commands() {
    local commands; commands=()
    _describe -t commands 'gix env commands' commands "$@"
}
(( $+functions[_gix__exclude_commands] )) ||
_gix__exclude_commands() {
    local commands; commands=(
'query:Check if path-specs are excluded and print the result similar to \`git check-ignore\`' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix exclude commands' commands "$@"
}
(( $+functions[_gix__exclude__help_commands] )) ||
_gix__exclude__help_commands() {
    local commands; commands=(
'query:Check if path-specs are excluded and print the result similar to \`git check-ignore\`' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix exclude help commands' commands "$@"
}
(( $+functions[_gix__exclude__help__help_commands] )) ||
_gix__exclude__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix exclude help help commands' commands "$@"
}
(( $+functions[_gix__exclude__help__query_commands] )) ||
_gix__exclude__help__query_commands() {
    local commands; commands=()
    _describe -t commands 'gix exclude help query commands' commands "$@"
}
(( $+functions[_gix__exclude__query_commands] )) ||
_gix__exclude__query_commands() {
    local commands; commands=()
    _describe -t commands 'gix exclude query commands' commands "$@"
}
(( $+functions[_gix__fetch_commands] )) ||
_gix__fetch_commands() {
    local commands; commands=()
    _describe -t commands 'gix fetch commands' commands "$@"
}
(( $+functions[_gix__free_commands] )) ||
_gix__free_commands() {
    local commands; commands=(
'commit-graph:Subcommands for interacting with commit-graphs' \
'mailmap:Subcommands for interacting with mailmaps' \
'pack:Subcommands for interacting with pack files and indices' \
'index:Subcommands for interacting with a worktree index, typically at .git/index' \
'discover:Show information about repository discovery and when opening a repository at the current path' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free commands' commands "$@"
}
(( $+functions[_gix__free__commit-graph_commands] )) ||
_gix__free__commit-graph_commands() {
    local commands; commands=(
'verify:Verify the integrity of a commit graph' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free commit-graph commands' commands "$@"
}
(( $+functions[_gix__free__commit-graph__help_commands] )) ||
_gix__free__commit-graph__help_commands() {
    local commands; commands=(
'verify:Verify the integrity of a commit graph' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free commit-graph help commands' commands "$@"
}
(( $+functions[_gix__free__commit-graph__help__help_commands] )) ||
_gix__free__commit-graph__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix free commit-graph help help commands' commands "$@"
}
(( $+functions[_gix__free__commit-graph__help__verify_commands] )) ||
_gix__free__commit-graph__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free commit-graph help verify commands' commands "$@"
}
(( $+functions[_gix__free__commit-graph__verify_commands] )) ||
_gix__free__commit-graph__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free commit-graph verify commands' commands "$@"
}
(( $+functions[_gix__free__discover_commands] )) ||
_gix__free__discover_commands() {
    local commands; commands=()
    _describe -t commands 'gix free discover commands' commands "$@"
}
(( $+functions[_gix__free__help_commands] )) ||
_gix__free__help_commands() {
    local commands; commands=(
'commit-graph:Subcommands for interacting with commit-graphs' \
'mailmap:Subcommands for interacting with mailmaps' \
'pack:Subcommands for interacting with pack files and indices' \
'index:Subcommands for interacting with a worktree index, typically at .git/index' \
'discover:Show information about repository discovery and when opening a repository at the current path' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free help commands' commands "$@"
}
(( $+functions[_gix__free__help__commit-graph_commands] )) ||
_gix__free__help__commit-graph_commands() {
    local commands; commands=(
'verify:Verify the integrity of a commit graph' \
    )
    _describe -t commands 'gix free help commit-graph commands' commands "$@"
}
(( $+functions[_gix__free__help__commit-graph__verify_commands] )) ||
_gix__free__help__commit-graph__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help commit-graph verify commands' commands "$@"
}
(( $+functions[_gix__free__help__discover_commands] )) ||
_gix__free__help__discover_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help discover commands' commands "$@"
}
(( $+functions[_gix__free__help__help_commands] )) ||
_gix__free__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help help commands' commands "$@"
}
(( $+functions[_gix__free__help__index_commands] )) ||
_gix__free__help__index_commands() {
    local commands; commands=(
'from-list:Create an index from a list of empty files, one per line of the input' \
'verify:Validate constraints and assumptions of an index along with its integrity' \
'info:Print information about the index structure' \
'checkout-exclusive:Checkout the index into a directory with exclusive write access, similar to what would happen during clone' \
    )
    _describe -t commands 'gix free help index commands' commands "$@"
}
(( $+functions[_gix__free__help__index__checkout-exclusive_commands] )) ||
_gix__free__help__index__checkout-exclusive_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help index checkout-exclusive commands' commands "$@"
}
(( $+functions[_gix__free__help__index__from-list_commands] )) ||
_gix__free__help__index__from-list_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help index from-list commands' commands "$@"
}
(( $+functions[_gix__free__help__index__info_commands] )) ||
_gix__free__help__index__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help index info commands' commands "$@"
}
(( $+functions[_gix__free__help__index__verify_commands] )) ||
_gix__free__help__index__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help index verify commands' commands "$@"
}
(( $+functions[_gix__free__help__mailmap_commands] )) ||
_gix__free__help__mailmap_commands() {
    local commands; commands=(
'verify:Parse all entries in the mailmap and report malformed lines or collisions' \
    )
    _describe -t commands 'gix free help mailmap commands' commands "$@"
}
(( $+functions[_gix__free__help__mailmap__verify_commands] )) ||
_gix__free__help__mailmap__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help mailmap verify commands' commands "$@"
}
(( $+functions[_gix__free__help__pack_commands] )) ||
_gix__free__help__pack_commands() {
    local commands; commands=(
'index:Subcommands for interacting with pack indices (.idx)' \
'multi-index:Subcommands for interacting with multi-pack indices (named "multi-pack-index")' \
'create:Create a new pack with a set of objects' \
'receive:Use the gix-protocol to receive a pack, emulating a clone' \
'explode:Dissolve a pack into its loose objects' \
'verify:Verify the integrity of a pack, index or multi-index file' \
    )
    _describe -t commands 'gix free help pack commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__create_commands] )) ||
_gix__free__help__pack__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack create commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__explode_commands] )) ||
_gix__free__help__pack__explode_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack explode commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__index_commands] )) ||
_gix__free__help__pack__index_commands() {
    local commands; commands=(
'create:create a pack index from a pack data file' \
    )
    _describe -t commands 'gix free help pack index commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__index__create_commands] )) ||
_gix__free__help__pack__index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack index create commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__multi-index_commands] )) ||
_gix__free__help__pack__multi-index_commands() {
    local commands; commands=(
'entries:Display all entries of a multi-index as\: *oid* *pack-id* *pack-offset*' \
'info:Print general information about a multi-index file' \
'verify:Verify a multi-index quickly without inspecting objects themselves' \
'create:Create a multi-pack index from one or more pack index files, overwriting possibly existing files' \
    )
    _describe -t commands 'gix free help pack multi-index commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__multi-index__create_commands] )) ||
_gix__free__help__pack__multi-index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack multi-index create commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__multi-index__entries_commands] )) ||
_gix__free__help__pack__multi-index__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack multi-index entries commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__multi-index__info_commands] )) ||
_gix__free__help__pack__multi-index__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack multi-index info commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__multi-index__verify_commands] )) ||
_gix__free__help__pack__multi-index__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack multi-index verify commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__receive_commands] )) ||
_gix__free__help__pack__receive_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack receive commands' commands "$@"
}
(( $+functions[_gix__free__help__pack__verify_commands] )) ||
_gix__free__help__pack__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free help pack verify commands' commands "$@"
}
(( $+functions[_gix__free__index_commands] )) ||
_gix__free__index_commands() {
    local commands; commands=(
'from-list:Create an index from a list of empty files, one per line of the input' \
'verify:Validate constraints and assumptions of an index along with its integrity' \
'info:Print information about the index structure' \
'checkout-exclusive:Checkout the index into a directory with exclusive write access, similar to what would happen during clone' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free index commands' commands "$@"
}
(( $+functions[_gix__free__index__checkout-exclusive_commands] )) ||
_gix__free__index__checkout-exclusive_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index checkout-exclusive commands' commands "$@"
}
(( $+functions[_gix__free__index__from-list_commands] )) ||
_gix__free__index__from-list_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index from-list commands' commands "$@"
}
(( $+functions[_gix__free__index__help_commands] )) ||
_gix__free__index__help_commands() {
    local commands; commands=(
'from-list:Create an index from a list of empty files, one per line of the input' \
'verify:Validate constraints and assumptions of an index along with its integrity' \
'info:Print information about the index structure' \
'checkout-exclusive:Checkout the index into a directory with exclusive write access, similar to what would happen during clone' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free index help commands' commands "$@"
}
(( $+functions[_gix__free__index__help__checkout-exclusive_commands] )) ||
_gix__free__index__help__checkout-exclusive_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index help checkout-exclusive commands' commands "$@"
}
(( $+functions[_gix__free__index__help__from-list_commands] )) ||
_gix__free__index__help__from-list_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index help from-list commands' commands "$@"
}
(( $+functions[_gix__free__index__help__help_commands] )) ||
_gix__free__index__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index help help commands' commands "$@"
}
(( $+functions[_gix__free__index__help__info_commands] )) ||
_gix__free__index__help__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index help info commands' commands "$@"
}
(( $+functions[_gix__free__index__help__verify_commands] )) ||
_gix__free__index__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index help verify commands' commands "$@"
}
(( $+functions[_gix__free__index__info_commands] )) ||
_gix__free__index__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index info commands' commands "$@"
}
(( $+functions[_gix__free__index__verify_commands] )) ||
_gix__free__index__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free index verify commands' commands "$@"
}
(( $+functions[_gix__free__mailmap_commands] )) ||
_gix__free__mailmap_commands() {
    local commands; commands=(
'verify:Parse all entries in the mailmap and report malformed lines or collisions' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free mailmap commands' commands "$@"
}
(( $+functions[_gix__free__mailmap__help_commands] )) ||
_gix__free__mailmap__help_commands() {
    local commands; commands=(
'verify:Parse all entries in the mailmap and report malformed lines or collisions' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free mailmap help commands' commands "$@"
}
(( $+functions[_gix__free__mailmap__help__help_commands] )) ||
_gix__free__mailmap__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix free mailmap help help commands' commands "$@"
}
(( $+functions[_gix__free__mailmap__help__verify_commands] )) ||
_gix__free__mailmap__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free mailmap help verify commands' commands "$@"
}
(( $+functions[_gix__free__mailmap__verify_commands] )) ||
_gix__free__mailmap__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free mailmap verify commands' commands "$@"
}
(( $+functions[_gix__free__pack_commands] )) ||
_gix__free__pack_commands() {
    local commands; commands=(
'index:Subcommands for interacting with pack indices (.idx)' \
'multi-index:Subcommands for interacting with multi-pack indices (named "multi-pack-index")' \
'create:Create a new pack with a set of objects' \
'receive:Use the gix-protocol to receive a pack, emulating a clone' \
'explode:Dissolve a pack into its loose objects' \
'verify:Verify the integrity of a pack, index or multi-index file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free pack commands' commands "$@"
}
(( $+functions[_gix__free__pack__create_commands] )) ||
_gix__free__pack__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack create commands' commands "$@"
}
(( $+functions[_gix__free__pack__explode_commands] )) ||
_gix__free__pack__explode_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack explode commands' commands "$@"
}
(( $+functions[_gix__free__pack__help_commands] )) ||
_gix__free__pack__help_commands() {
    local commands; commands=(
'index:Subcommands for interacting with pack indices (.idx)' \
'multi-index:Subcommands for interacting with multi-pack indices (named "multi-pack-index")' \
'create:Create a new pack with a set of objects' \
'receive:Use the gix-protocol to receive a pack, emulating a clone' \
'explode:Dissolve a pack into its loose objects' \
'verify:Verify the integrity of a pack, index or multi-index file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free pack help commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__create_commands] )) ||
_gix__free__pack__help__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help create commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__explode_commands] )) ||
_gix__free__pack__help__explode_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help explode commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__help_commands] )) ||
_gix__free__pack__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help help commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__index_commands] )) ||
_gix__free__pack__help__index_commands() {
    local commands; commands=(
'create:create a pack index from a pack data file' \
    )
    _describe -t commands 'gix free pack help index commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__index__create_commands] )) ||
_gix__free__pack__help__index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help index create commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__multi-index_commands] )) ||
_gix__free__pack__help__multi-index_commands() {
    local commands; commands=(
'entries:Display all entries of a multi-index as\: *oid* *pack-id* *pack-offset*' \
'info:Print general information about a multi-index file' \
'verify:Verify a multi-index quickly without inspecting objects themselves' \
'create:Create a multi-pack index from one or more pack index files, overwriting possibly existing files' \
    )
    _describe -t commands 'gix free pack help multi-index commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__multi-index__create_commands] )) ||
_gix__free__pack__help__multi-index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help multi-index create commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__multi-index__entries_commands] )) ||
_gix__free__pack__help__multi-index__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help multi-index entries commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__multi-index__info_commands] )) ||
_gix__free__pack__help__multi-index__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help multi-index info commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__multi-index__verify_commands] )) ||
_gix__free__pack__help__multi-index__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help multi-index verify commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__receive_commands] )) ||
_gix__free__pack__help__receive_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help receive commands' commands "$@"
}
(( $+functions[_gix__free__pack__help__verify_commands] )) ||
_gix__free__pack__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack help verify commands' commands "$@"
}
(( $+functions[_gix__free__pack__index_commands] )) ||
_gix__free__pack__index_commands() {
    local commands; commands=(
'create:create a pack index from a pack data file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free pack index commands' commands "$@"
}
(( $+functions[_gix__free__pack__index__create_commands] )) ||
_gix__free__pack__index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack index create commands' commands "$@"
}
(( $+functions[_gix__free__pack__index__help_commands] )) ||
_gix__free__pack__index__help_commands() {
    local commands; commands=(
'create:create a pack index from a pack data file' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free pack index help commands' commands "$@"
}
(( $+functions[_gix__free__pack__index__help__create_commands] )) ||
_gix__free__pack__index__help__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack index help create commands' commands "$@"
}
(( $+functions[_gix__free__pack__index__help__help_commands] )) ||
_gix__free__pack__index__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack index help help commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index_commands] )) ||
_gix__free__pack__multi-index_commands() {
    local commands; commands=(
'entries:Display all entries of a multi-index as\: *oid* *pack-id* *pack-offset*' \
'info:Print general information about a multi-index file' \
'verify:Verify a multi-index quickly without inspecting objects themselves' \
'create:Create a multi-pack index from one or more pack index files, overwriting possibly existing files' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free pack multi-index commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__create_commands] )) ||
_gix__free__pack__multi-index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index create commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__entries_commands] )) ||
_gix__free__pack__multi-index__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index entries commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__help_commands] )) ||
_gix__free__pack__multi-index__help_commands() {
    local commands; commands=(
'entries:Display all entries of a multi-index as\: *oid* *pack-id* *pack-offset*' \
'info:Print general information about a multi-index file' \
'verify:Verify a multi-index quickly without inspecting objects themselves' \
'create:Create a multi-pack index from one or more pack index files, overwriting possibly existing files' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix free pack multi-index help commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__help__create_commands] )) ||
_gix__free__pack__multi-index__help__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index help create commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__help__entries_commands] )) ||
_gix__free__pack__multi-index__help__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index help entries commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__help__help_commands] )) ||
_gix__free__pack__multi-index__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index help help commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__help__info_commands] )) ||
_gix__free__pack__multi-index__help__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index help info commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__help__verify_commands] )) ||
_gix__free__pack__multi-index__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index help verify commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__info_commands] )) ||
_gix__free__pack__multi-index__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index info commands' commands "$@"
}
(( $+functions[_gix__free__pack__multi-index__verify_commands] )) ||
_gix__free__pack__multi-index__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack multi-index verify commands' commands "$@"
}
(( $+functions[_gix__free__pack__receive_commands] )) ||
_gix__free__pack__receive_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack receive commands' commands "$@"
}
(( $+functions[_gix__free__pack__verify_commands] )) ||
_gix__free__pack__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix free pack verify commands' commands "$@"
}
(( $+functions[_gix__fsck_commands] )) ||
_gix__fsck_commands() {
    local commands; commands=()
    _describe -t commands 'gix fsck commands' commands "$@"
}
(( $+functions[_gix__help_commands] )) ||
_gix__help_commands() {
    local commands; commands=(
'archive:Subcommands for creating worktree archives' \
'clean:Remove untracked files from the working tree' \
'commit-graph:Subcommands for interacting with commit-graph files' \
'odb:Interact with the object database' \
'fsck:Check for missing objects' \
'tree:Interact with tree objects' \
'commit:Interact with commit objects' \
'tag:Interact with tag objects' \
'verify:Verify the integrity of the entire repository' \
'revision:Query and obtain information about revisions' \
'credential:A program just like \`git credential\`' \
'fetch:Fetch data from remotes and store it in the repository' \
'clone:Clone a repository into a new directory' \
'mailmap:Interact with the mailmap' \
'remote:Interact with the remote hosts' \
'attributes:Interact with the attribute files like .gitattributes' \
'exclude:Interact with the exclude files like .gitignore' \
'index:Interact with a worktree index like .git/index' \
'submodule:Interact with submodules' \
'cat:Show whatever object is at the given spec' \
'is-clean:Check for changes in the repository, treating this as an error' \
'is-changed:Check for changes in the repository, treating their absence as an error' \
'config-tree:Show which git configuration values are used or planned' \
'status:Compute repository status similar to \`git status\`' \
'config:Print all entries in a configuration file or access other sub-commands' \
'merge-base:A command for calculating all merge-bases' \
'merge:Perform merges of various kinds' \
'env:Print paths relevant to the Git installation' \
'diff:Print all changes between two objects' \
'log:List all commits in a repository, optionally limited to those that change a given path' \
'worktree:Commands for handling worktrees' \
'free:Subcommands that need no Git repository to run' \
'blame:Blame lines in a file' \
'completions:Generate shell completions to stdout or a directory' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix help commands' commands "$@"
}
(( $+functions[_gix__help__archive_commands] )) ||
_gix__help__archive_commands() {
    local commands; commands=()
    _describe -t commands 'gix help archive commands' commands "$@"
}
(( $+functions[_gix__help__attributes_commands] )) ||
_gix__help__attributes_commands() {
    local commands; commands=(
'validate-baseline:Run \`git check-attr\` and \`git check-ignore\` on all files of the index or all files passed via stdin and validate that we get the same outcome when computing attributes' \
'query:List all attributes of the given path-specs and display the result similar to \`git check-attr\`' \
    )
    _describe -t commands 'gix help attributes commands' commands "$@"
}
(( $+functions[_gix__help__attributes__query_commands] )) ||
_gix__help__attributes__query_commands() {
    local commands; commands=()
    _describe -t commands 'gix help attributes query commands' commands "$@"
}
(( $+functions[_gix__help__attributes__validate-baseline_commands] )) ||
_gix__help__attributes__validate-baseline_commands() {
    local commands; commands=()
    _describe -t commands 'gix help attributes validate-baseline commands' commands "$@"
}
(( $+functions[_gix__help__blame_commands] )) ||
_gix__help__blame_commands() {
    local commands; commands=()
    _describe -t commands 'gix help blame commands' commands "$@"
}
(( $+functions[_gix__help__cat_commands] )) ||
_gix__help__cat_commands() {
    local commands; commands=()
    _describe -t commands 'gix help cat commands' commands "$@"
}
(( $+functions[_gix__help__clean_commands] )) ||
_gix__help__clean_commands() {
    local commands; commands=()
    _describe -t commands 'gix help clean commands' commands "$@"
}
(( $+functions[_gix__help__clone_commands] )) ||
_gix__help__clone_commands() {
    local commands; commands=()
    _describe -t commands 'gix help clone commands' commands "$@"
}
(( $+functions[_gix__help__commit_commands] )) ||
_gix__help__commit_commands() {
    local commands; commands=(
'verify:Verify the signature of a commit' \
'describe:Describe the current commit or the given one using the name of the closest annotated tag in its ancestry' \
    )
    _describe -t commands 'gix help commit commands' commands "$@"
}
(( $+functions[_gix__help__commit__describe_commands] )) ||
_gix__help__commit__describe_commands() {
    local commands; commands=()
    _describe -t commands 'gix help commit describe commands' commands "$@"
}
(( $+functions[_gix__help__commit__verify_commands] )) ||
_gix__help__commit__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help commit verify commands' commands "$@"
}
(( $+functions[_gix__help__commit-graph_commands] )) ||
_gix__help__commit-graph_commands() {
    local commands; commands=(
'verify:Verify the integrity of a commit graph file' \
'list:List all entries in the commit-graph file as reachable by starting from \`HEAD\`' \
    )
    _describe -t commands 'gix help commit-graph commands' commands "$@"
}
(( $+functions[_gix__help__commit-graph__list_commands] )) ||
_gix__help__commit-graph__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix help commit-graph list commands' commands "$@"
}
(( $+functions[_gix__help__commit-graph__verify_commands] )) ||
_gix__help__commit-graph__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help commit-graph verify commands' commands "$@"
}
(( $+functions[_gix__help__completions_commands] )) ||
_gix__help__completions_commands() {
    local commands; commands=()
    _describe -t commands 'gix help completions commands' commands "$@"
}
(( $+functions[_gix__help__config_commands] )) ||
_gix__help__config_commands() {
    local commands; commands=()
    _describe -t commands 'gix help config commands' commands "$@"
}
(( $+functions[_gix__help__config-tree_commands] )) ||
_gix__help__config-tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix help config-tree commands' commands "$@"
}
(( $+functions[_gix__help__credential_commands] )) ||
_gix__help__credential_commands() {
    local commands; commands=(
'fill:Get the credentials fed for \`url=<url>\` via STDIN' \
'approve:Approve the information piped via STDIN as obtained with last call to \`fill\`' \
'reject:Try to resolve the given revspec and print the object names' \
    )
    _describe -t commands 'gix help credential commands' commands "$@"
}
(( $+functions[_gix__help__credential__approve_commands] )) ||
_gix__help__credential__approve_commands() {
    local commands; commands=()
    _describe -t commands 'gix help credential approve commands' commands "$@"
}
(( $+functions[_gix__help__credential__fill_commands] )) ||
_gix__help__credential__fill_commands() {
    local commands; commands=()
    _describe -t commands 'gix help credential fill commands' commands "$@"
}
(( $+functions[_gix__help__credential__reject_commands] )) ||
_gix__help__credential__reject_commands() {
    local commands; commands=()
    _describe -t commands 'gix help credential reject commands' commands "$@"
}
(( $+functions[_gix__help__diff_commands] )) ||
_gix__help__diff_commands() {
    local commands; commands=(
'tree:Diff two trees' \
'file:Diff two versions of a file' \
    )
    _describe -t commands 'gix help diff commands' commands "$@"
}
(( $+functions[_gix__help__diff__file_commands] )) ||
_gix__help__diff__file_commands() {
    local commands; commands=()
    _describe -t commands 'gix help diff file commands' commands "$@"
}
(( $+functions[_gix__help__diff__tree_commands] )) ||
_gix__help__diff__tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix help diff tree commands' commands "$@"
}
(( $+functions[_gix__help__env_commands] )) ||
_gix__help__env_commands() {
    local commands; commands=()
    _describe -t commands 'gix help env commands' commands "$@"
}
(( $+functions[_gix__help__exclude_commands] )) ||
_gix__help__exclude_commands() {
    local commands; commands=(
'query:Check if path-specs are excluded and print the result similar to \`git check-ignore\`' \
    )
    _describe -t commands 'gix help exclude commands' commands "$@"
}
(( $+functions[_gix__help__exclude__query_commands] )) ||
_gix__help__exclude__query_commands() {
    local commands; commands=()
    _describe -t commands 'gix help exclude query commands' commands "$@"
}
(( $+functions[_gix__help__fetch_commands] )) ||
_gix__help__fetch_commands() {
    local commands; commands=()
    _describe -t commands 'gix help fetch commands' commands "$@"
}
(( $+functions[_gix__help__free_commands] )) ||
_gix__help__free_commands() {
    local commands; commands=(
'commit-graph:Subcommands for interacting with commit-graphs' \
'mailmap:Subcommands for interacting with mailmaps' \
'pack:Subcommands for interacting with pack files and indices' \
'index:Subcommands for interacting with a worktree index, typically at .git/index' \
'discover:Show information about repository discovery and when opening a repository at the current path' \
    )
    _describe -t commands 'gix help free commands' commands "$@"
}
(( $+functions[_gix__help__free__commit-graph_commands] )) ||
_gix__help__free__commit-graph_commands() {
    local commands; commands=(
'verify:Verify the integrity of a commit graph' \
    )
    _describe -t commands 'gix help free commit-graph commands' commands "$@"
}
(( $+functions[_gix__help__free__commit-graph__verify_commands] )) ||
_gix__help__free__commit-graph__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free commit-graph verify commands' commands "$@"
}
(( $+functions[_gix__help__free__discover_commands] )) ||
_gix__help__free__discover_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free discover commands' commands "$@"
}
(( $+functions[_gix__help__free__index_commands] )) ||
_gix__help__free__index_commands() {
    local commands; commands=(
'from-list:Create an index from a list of empty files, one per line of the input' \
'verify:Validate constraints and assumptions of an index along with its integrity' \
'info:Print information about the index structure' \
'checkout-exclusive:Checkout the index into a directory with exclusive write access, similar to what would happen during clone' \
    )
    _describe -t commands 'gix help free index commands' commands "$@"
}
(( $+functions[_gix__help__free__index__checkout-exclusive_commands] )) ||
_gix__help__free__index__checkout-exclusive_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free index checkout-exclusive commands' commands "$@"
}
(( $+functions[_gix__help__free__index__from-list_commands] )) ||
_gix__help__free__index__from-list_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free index from-list commands' commands "$@"
}
(( $+functions[_gix__help__free__index__info_commands] )) ||
_gix__help__free__index__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free index info commands' commands "$@"
}
(( $+functions[_gix__help__free__index__verify_commands] )) ||
_gix__help__free__index__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free index verify commands' commands "$@"
}
(( $+functions[_gix__help__free__mailmap_commands] )) ||
_gix__help__free__mailmap_commands() {
    local commands; commands=(
'verify:Parse all entries in the mailmap and report malformed lines or collisions' \
    )
    _describe -t commands 'gix help free mailmap commands' commands "$@"
}
(( $+functions[_gix__help__free__mailmap__verify_commands] )) ||
_gix__help__free__mailmap__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free mailmap verify commands' commands "$@"
}
(( $+functions[_gix__help__free__pack_commands] )) ||
_gix__help__free__pack_commands() {
    local commands; commands=(
'index:Subcommands for interacting with pack indices (.idx)' \
'multi-index:Subcommands for interacting with multi-pack indices (named "multi-pack-index")' \
'create:Create a new pack with a set of objects' \
'receive:Use the gix-protocol to receive a pack, emulating a clone' \
'explode:Dissolve a pack into its loose objects' \
'verify:Verify the integrity of a pack, index or multi-index file' \
    )
    _describe -t commands 'gix help free pack commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__create_commands] )) ||
_gix__help__free__pack__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack create commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__explode_commands] )) ||
_gix__help__free__pack__explode_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack explode commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__index_commands] )) ||
_gix__help__free__pack__index_commands() {
    local commands; commands=(
'create:create a pack index from a pack data file' \
    )
    _describe -t commands 'gix help free pack index commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__index__create_commands] )) ||
_gix__help__free__pack__index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack index create commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__multi-index_commands] )) ||
_gix__help__free__pack__multi-index_commands() {
    local commands; commands=(
'entries:Display all entries of a multi-index as\: *oid* *pack-id* *pack-offset*' \
'info:Print general information about a multi-index file' \
'verify:Verify a multi-index quickly without inspecting objects themselves' \
'create:Create a multi-pack index from one or more pack index files, overwriting possibly existing files' \
    )
    _describe -t commands 'gix help free pack multi-index commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__multi-index__create_commands] )) ||
_gix__help__free__pack__multi-index__create_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack multi-index create commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__multi-index__entries_commands] )) ||
_gix__help__free__pack__multi-index__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack multi-index entries commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__multi-index__info_commands] )) ||
_gix__help__free__pack__multi-index__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack multi-index info commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__multi-index__verify_commands] )) ||
_gix__help__free__pack__multi-index__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack multi-index verify commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__receive_commands] )) ||
_gix__help__free__pack__receive_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack receive commands' commands "$@"
}
(( $+functions[_gix__help__free__pack__verify_commands] )) ||
_gix__help__free__pack__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help free pack verify commands' commands "$@"
}
(( $+functions[_gix__help__fsck_commands] )) ||
_gix__help__fsck_commands() {
    local commands; commands=()
    _describe -t commands 'gix help fsck commands' commands "$@"
}
(( $+functions[_gix__help__help_commands] )) ||
_gix__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix help help commands' commands "$@"
}
(( $+functions[_gix__help__index_commands] )) ||
_gix__help__index_commands() {
    local commands; commands=(
'entries:Print all entries to standard output' \
'from-tree:Create an index from a tree-ish' \
    )
    _describe -t commands 'gix help index commands' commands "$@"
}
(( $+functions[_gix__help__index__entries_commands] )) ||
_gix__help__index__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix help index entries commands' commands "$@"
}
(( $+functions[_gix__help__index__from-tree_commands] )) ||
_gix__help__index__from-tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix help index from-tree commands' commands "$@"
}
(( $+functions[_gix__help__is-changed_commands] )) ||
_gix__help__is-changed_commands() {
    local commands; commands=()
    _describe -t commands 'gix help is-changed commands' commands "$@"
}
(( $+functions[_gix__help__is-clean_commands] )) ||
_gix__help__is-clean_commands() {
    local commands; commands=()
    _describe -t commands 'gix help is-clean commands' commands "$@"
}
(( $+functions[_gix__help__log_commands] )) ||
_gix__help__log_commands() {
    local commands; commands=()
    _describe -t commands 'gix help log commands' commands "$@"
}
(( $+functions[_gix__help__mailmap_commands] )) ||
_gix__help__mailmap_commands() {
    local commands; commands=(
'entries:Print all entries in configured mailmaps, inform about errors as well' \
'check:Print the canonical form of contacts according to the configured mailmaps' \
    )
    _describe -t commands 'gix help mailmap commands' commands "$@"
}
(( $+functions[_gix__help__mailmap__check_commands] )) ||
_gix__help__mailmap__check_commands() {
    local commands; commands=()
    _describe -t commands 'gix help mailmap check commands' commands "$@"
}
(( $+functions[_gix__help__mailmap__entries_commands] )) ||
_gix__help__mailmap__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix help mailmap entries commands' commands "$@"
}
(( $+functions[_gix__help__merge_commands] )) ||
_gix__help__merge_commands() {
    local commands; commands=(
'file:Merge a file by specifying ours, base and theirs' \
'tree:Merge a tree by specifying ours, base and theirs, writing it to the object database' \
'commit:Merge a commits by specifying ours, and theirs, writing the tree to the object database' \
    )
    _describe -t commands 'gix help merge commands' commands "$@"
}
(( $+functions[_gix__help__merge__commit_commands] )) ||
_gix__help__merge__commit_commands() {
    local commands; commands=()
    _describe -t commands 'gix help merge commit commands' commands "$@"
}
(( $+functions[_gix__help__merge__file_commands] )) ||
_gix__help__merge__file_commands() {
    local commands; commands=()
    _describe -t commands 'gix help merge file commands' commands "$@"
}
(( $+functions[_gix__help__merge__tree_commands] )) ||
_gix__help__merge__tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix help merge tree commands' commands "$@"
}
(( $+functions[_gix__help__merge-base_commands] )) ||
_gix__help__merge-base_commands() {
    local commands; commands=()
    _describe -t commands 'gix help merge-base commands' commands "$@"
}
(( $+functions[_gix__help__odb_commands] )) ||
_gix__help__odb_commands() {
    local commands; commands=(
'entries:Print all object names' \
'info:Provide general information about the object database' \
'stats:Count and obtain information on all, possibly duplicate, objects in the database' \
    )
    _describe -t commands 'gix help odb commands' commands "$@"
}
(( $+functions[_gix__help__odb__entries_commands] )) ||
_gix__help__odb__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix help odb entries commands' commands "$@"
}
(( $+functions[_gix__help__odb__info_commands] )) ||
_gix__help__odb__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix help odb info commands' commands "$@"
}
(( $+functions[_gix__help__odb__stats_commands] )) ||
_gix__help__odb__stats_commands() {
    local commands; commands=()
    _describe -t commands 'gix help odb stats commands' commands "$@"
}
(( $+functions[_gix__help__remote_commands] )) ||
_gix__help__remote_commands() {
    local commands; commands=(
'refs:Print all references available on the remote' \
'ref-map:Print all references available on the remote as filtered through ref-specs' \
    )
    _describe -t commands 'gix help remote commands' commands "$@"
}
(( $+functions[_gix__help__remote__ref-map_commands] )) ||
_gix__help__remote__ref-map_commands() {
    local commands; commands=()
    _describe -t commands 'gix help remote ref-map commands' commands "$@"
}
(( $+functions[_gix__help__remote__refs_commands] )) ||
_gix__help__remote__refs_commands() {
    local commands; commands=()
    _describe -t commands 'gix help remote refs commands' commands "$@"
}
(( $+functions[_gix__help__revision_commands] )) ||
_gix__help__revision_commands() {
    local commands; commands=(
'list:List all commits reachable from the given rev-spec' \
'explain:Provide the revision specification like \`@~1\` to explain' \
'resolve:Try to resolve the given revspec and print the object names' \
'previous-branches:Return the names and hashes of all previously checked-out branches' \
    )
    _describe -t commands 'gix help revision commands' commands "$@"
}
(( $+functions[_gix__help__revision__explain_commands] )) ||
_gix__help__revision__explain_commands() {
    local commands; commands=()
    _describe -t commands 'gix help revision explain commands' commands "$@"
}
(( $+functions[_gix__help__revision__list_commands] )) ||
_gix__help__revision__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix help revision list commands' commands "$@"
}
(( $+functions[_gix__help__revision__previous-branches_commands] )) ||
_gix__help__revision__previous-branches_commands() {
    local commands; commands=()
    _describe -t commands 'gix help revision previous-branches commands' commands "$@"
}
(( $+functions[_gix__help__revision__resolve_commands] )) ||
_gix__help__revision__resolve_commands() {
    local commands; commands=()
    _describe -t commands 'gix help revision resolve commands' commands "$@"
}
(( $+functions[_gix__help__status_commands] )) ||
_gix__help__status_commands() {
    local commands; commands=()
    _describe -t commands 'gix help status commands' commands "$@"
}
(( $+functions[_gix__help__submodule_commands] )) ||
_gix__help__submodule_commands() {
    local commands; commands=(
'list:Print all direct submodules to standard output' \
    )
    _describe -t commands 'gix help submodule commands' commands "$@"
}
(( $+functions[_gix__help__submodule__list_commands] )) ||
_gix__help__submodule__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix help submodule list commands' commands "$@"
}
(( $+functions[_gix__help__tag_commands] )) ||
_gix__help__tag_commands() {
    local commands; commands=(
'list:List all tags' \
    )
    _describe -t commands 'gix help tag commands' commands "$@"
}
(( $+functions[_gix__help__tag__list_commands] )) ||
_gix__help__tag__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix help tag list commands' commands "$@"
}
(( $+functions[_gix__help__tree_commands] )) ||
_gix__help__tree_commands() {
    local commands; commands=(
'entries:Print entries in a given tree' \
'info:Provide information about a tree' \
    )
    _describe -t commands 'gix help tree commands' commands "$@"
}
(( $+functions[_gix__help__tree__entries_commands] )) ||
_gix__help__tree__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix help tree entries commands' commands "$@"
}
(( $+functions[_gix__help__tree__info_commands] )) ||
_gix__help__tree__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix help tree info commands' commands "$@"
}
(( $+functions[_gix__help__verify_commands] )) ||
_gix__help__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix help verify commands' commands "$@"
}
(( $+functions[_gix__help__worktree_commands] )) ||
_gix__help__worktree_commands() {
    local commands; commands=(
'list:List all worktrees, along with some accompanying information' \
    )
    _describe -t commands 'gix help worktree commands' commands "$@"
}
(( $+functions[_gix__help__worktree__list_commands] )) ||
_gix__help__worktree__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix help worktree list commands' commands "$@"
}
(( $+functions[_gix__index_commands] )) ||
_gix__index_commands() {
    local commands; commands=(
'entries:Print all entries to standard output' \
'from-tree:Create an index from a tree-ish' \
'read-tree:Create an index from a tree-ish' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix index commands' commands "$@"
}
(( $+functions[_gix__index__entries_commands] )) ||
_gix__index__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix index entries commands' commands "$@"
}
(( $+functions[_gix__index__from-tree_commands] )) ||
_gix__index__from-tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix index from-tree commands' commands "$@"
}
(( $+functions[_gix__index__help_commands] )) ||
_gix__index__help_commands() {
    local commands; commands=(
'entries:Print all entries to standard output' \
'from-tree:Create an index from a tree-ish' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix index help commands' commands "$@"
}
(( $+functions[_gix__index__help__entries_commands] )) ||
_gix__index__help__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix index help entries commands' commands "$@"
}
(( $+functions[_gix__index__help__from-tree_commands] )) ||
_gix__index__help__from-tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix index help from-tree commands' commands "$@"
}
(( $+functions[_gix__index__help__help_commands] )) ||
_gix__index__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix index help help commands' commands "$@"
}
(( $+functions[_gix__is-changed_commands] )) ||
_gix__is-changed_commands() {
    local commands; commands=()
    _describe -t commands 'gix is-changed commands' commands "$@"
}
(( $+functions[_gix__is-clean_commands] )) ||
_gix__is-clean_commands() {
    local commands; commands=()
    _describe -t commands 'gix is-clean commands' commands "$@"
}
(( $+functions[_gix__log_commands] )) ||
_gix__log_commands() {
    local commands; commands=()
    _describe -t commands 'gix log commands' commands "$@"
}
(( $+functions[_gix__mailmap_commands] )) ||
_gix__mailmap_commands() {
    local commands; commands=(
'entries:Print all entries in configured mailmaps, inform about errors as well' \
'check:Print the canonical form of contacts according to the configured mailmaps' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix mailmap commands' commands "$@"
}
(( $+functions[_gix__mailmap__check_commands] )) ||
_gix__mailmap__check_commands() {
    local commands; commands=()
    _describe -t commands 'gix mailmap check commands' commands "$@"
}
(( $+functions[_gix__mailmap__entries_commands] )) ||
_gix__mailmap__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix mailmap entries commands' commands "$@"
}
(( $+functions[_gix__mailmap__help_commands] )) ||
_gix__mailmap__help_commands() {
    local commands; commands=(
'entries:Print all entries in configured mailmaps, inform about errors as well' \
'check:Print the canonical form of contacts according to the configured mailmaps' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix mailmap help commands' commands "$@"
}
(( $+functions[_gix__mailmap__help__check_commands] )) ||
_gix__mailmap__help__check_commands() {
    local commands; commands=()
    _describe -t commands 'gix mailmap help check commands' commands "$@"
}
(( $+functions[_gix__mailmap__help__entries_commands] )) ||
_gix__mailmap__help__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix mailmap help entries commands' commands "$@"
}
(( $+functions[_gix__mailmap__help__help_commands] )) ||
_gix__mailmap__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix mailmap help help commands' commands "$@"
}
(( $+functions[_gix__merge_commands] )) ||
_gix__merge_commands() {
    local commands; commands=(
'file:Merge a file by specifying ours, base and theirs' \
'tree:Merge a tree by specifying ours, base and theirs, writing it to the object database' \
'commit:Merge a commits by specifying ours, and theirs, writing the tree to the object database' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix merge commands' commands "$@"
}
(( $+functions[_gix__merge__commit_commands] )) ||
_gix__merge__commit_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge commit commands' commands "$@"
}
(( $+functions[_gix__merge__file_commands] )) ||
_gix__merge__file_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge file commands' commands "$@"
}
(( $+functions[_gix__merge__help_commands] )) ||
_gix__merge__help_commands() {
    local commands; commands=(
'file:Merge a file by specifying ours, base and theirs' \
'tree:Merge a tree by specifying ours, base and theirs, writing it to the object database' \
'commit:Merge a commits by specifying ours, and theirs, writing the tree to the object database' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix merge help commands' commands "$@"
}
(( $+functions[_gix__merge__help__commit_commands] )) ||
_gix__merge__help__commit_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge help commit commands' commands "$@"
}
(( $+functions[_gix__merge__help__file_commands] )) ||
_gix__merge__help__file_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge help file commands' commands "$@"
}
(( $+functions[_gix__merge__help__help_commands] )) ||
_gix__merge__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge help help commands' commands "$@"
}
(( $+functions[_gix__merge__help__tree_commands] )) ||
_gix__merge__help__tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge help tree commands' commands "$@"
}
(( $+functions[_gix__merge__tree_commands] )) ||
_gix__merge__tree_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge tree commands' commands "$@"
}
(( $+functions[_gix__merge-base_commands] )) ||
_gix__merge-base_commands() {
    local commands; commands=()
    _describe -t commands 'gix merge-base commands' commands "$@"
}
(( $+functions[_gix__odb_commands] )) ||
_gix__odb_commands() {
    local commands; commands=(
'entries:Print all object names' \
'info:Provide general information about the object database' \
'stats:Count and obtain information on all, possibly duplicate, objects in the database' \
'statistics:Count and obtain information on all, possibly duplicate, objects in the database' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix odb commands' commands "$@"
}
(( $+functions[_gix__odb__entries_commands] )) ||
_gix__odb__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix odb entries commands' commands "$@"
}
(( $+functions[_gix__odb__help_commands] )) ||
_gix__odb__help_commands() {
    local commands; commands=(
'entries:Print all object names' \
'info:Provide general information about the object database' \
'stats:Count and obtain information on all, possibly duplicate, objects in the database' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix odb help commands' commands "$@"
}
(( $+functions[_gix__odb__help__entries_commands] )) ||
_gix__odb__help__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix odb help entries commands' commands "$@"
}
(( $+functions[_gix__odb__help__help_commands] )) ||
_gix__odb__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix odb help help commands' commands "$@"
}
(( $+functions[_gix__odb__help__info_commands] )) ||
_gix__odb__help__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix odb help info commands' commands "$@"
}
(( $+functions[_gix__odb__help__stats_commands] )) ||
_gix__odb__help__stats_commands() {
    local commands; commands=()
    _describe -t commands 'gix odb help stats commands' commands "$@"
}
(( $+functions[_gix__odb__info_commands] )) ||
_gix__odb__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix odb info commands' commands "$@"
}
(( $+functions[_gix__odb__stats_commands] )) ||
_gix__odb__stats_commands() {
    local commands; commands=()
    _describe -t commands 'gix odb stats commands' commands "$@"
}
(( $+functions[_gix__remote_commands] )) ||
_gix__remote_commands() {
    local commands; commands=(
'refs:Print all references available on the remote' \
'ref-map:Print all references available on the remote as filtered through ref-specs' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix remote commands' commands "$@"
}
(( $+functions[_gix__remote__help_commands] )) ||
_gix__remote__help_commands() {
    local commands; commands=(
'refs:Print all references available on the remote' \
'ref-map:Print all references available on the remote as filtered through ref-specs' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix remote help commands' commands "$@"
}
(( $+functions[_gix__remote__help__help_commands] )) ||
_gix__remote__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix remote help help commands' commands "$@"
}
(( $+functions[_gix__remote__help__ref-map_commands] )) ||
_gix__remote__help__ref-map_commands() {
    local commands; commands=()
    _describe -t commands 'gix remote help ref-map commands' commands "$@"
}
(( $+functions[_gix__remote__help__refs_commands] )) ||
_gix__remote__help__refs_commands() {
    local commands; commands=()
    _describe -t commands 'gix remote help refs commands' commands "$@"
}
(( $+functions[_gix__remote__ref-map_commands] )) ||
_gix__remote__ref-map_commands() {
    local commands; commands=()
    _describe -t commands 'gix remote ref-map commands' commands "$@"
}
(( $+functions[_gix__remote__refs_commands] )) ||
_gix__remote__refs_commands() {
    local commands; commands=()
    _describe -t commands 'gix remote refs commands' commands "$@"
}
(( $+functions[_gix__revision_commands] )) ||
_gix__revision_commands() {
    local commands; commands=(
'list:List all commits reachable from the given rev-spec' \
'l:List all commits reachable from the given rev-spec' \
'explain:Provide the revision specification like \`@~1\` to explain' \
'e:Provide the revision specification like \`@~1\` to explain' \
'resolve:Try to resolve the given revspec and print the object names' \
'query:Try to resolve the given revspec and print the object names' \
'parse:Try to resolve the given revspec and print the object names' \
'p:Try to resolve the given revspec and print the object names' \
'previous-branches:Return the names and hashes of all previously checked-out branches' \
'prev:Return the names and hashes of all previously checked-out branches' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix revision commands' commands "$@"
}
(( $+functions[_gix__revision__explain_commands] )) ||
_gix__revision__explain_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision explain commands' commands "$@"
}
(( $+functions[_gix__revision__help_commands] )) ||
_gix__revision__help_commands() {
    local commands; commands=(
'list:List all commits reachable from the given rev-spec' \
'explain:Provide the revision specification like \`@~1\` to explain' \
'resolve:Try to resolve the given revspec and print the object names' \
'previous-branches:Return the names and hashes of all previously checked-out branches' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix revision help commands' commands "$@"
}
(( $+functions[_gix__revision__help__explain_commands] )) ||
_gix__revision__help__explain_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision help explain commands' commands "$@"
}
(( $+functions[_gix__revision__help__help_commands] )) ||
_gix__revision__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision help help commands' commands "$@"
}
(( $+functions[_gix__revision__help__list_commands] )) ||
_gix__revision__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision help list commands' commands "$@"
}
(( $+functions[_gix__revision__help__previous-branches_commands] )) ||
_gix__revision__help__previous-branches_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision help previous-branches commands' commands "$@"
}
(( $+functions[_gix__revision__help__resolve_commands] )) ||
_gix__revision__help__resolve_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision help resolve commands' commands "$@"
}
(( $+functions[_gix__revision__list_commands] )) ||
_gix__revision__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision list commands' commands "$@"
}
(( $+functions[_gix__revision__previous-branches_commands] )) ||
_gix__revision__previous-branches_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision previous-branches commands' commands "$@"
}
(( $+functions[_gix__revision__resolve_commands] )) ||
_gix__revision__resolve_commands() {
    local commands; commands=()
    _describe -t commands 'gix revision resolve commands' commands "$@"
}
(( $+functions[_gix__status_commands] )) ||
_gix__status_commands() {
    local commands; commands=()
    _describe -t commands 'gix status commands' commands "$@"
}
(( $+functions[_gix__submodule_commands] )) ||
_gix__submodule_commands() {
    local commands; commands=(
'list:Print all direct submodules to standard output' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix submodule commands' commands "$@"
}
(( $+functions[_gix__submodule__help_commands] )) ||
_gix__submodule__help_commands() {
    local commands; commands=(
'list:Print all direct submodules to standard output' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix submodule help commands' commands "$@"
}
(( $+functions[_gix__submodule__help__help_commands] )) ||
_gix__submodule__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix submodule help help commands' commands "$@"
}
(( $+functions[_gix__submodule__help__list_commands] )) ||
_gix__submodule__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix submodule help list commands' commands "$@"
}
(( $+functions[_gix__submodule__list_commands] )) ||
_gix__submodule__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix submodule list commands' commands "$@"
}
(( $+functions[_gix__tag_commands] )) ||
_gix__tag_commands() {
    local commands; commands=(
'list:List all tags' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix tag commands' commands "$@"
}
(( $+functions[_gix__tag__help_commands] )) ||
_gix__tag__help_commands() {
    local commands; commands=(
'list:List all tags' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix tag help commands' commands "$@"
}
(( $+functions[_gix__tag__help__help_commands] )) ||
_gix__tag__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix tag help help commands' commands "$@"
}
(( $+functions[_gix__tag__help__list_commands] )) ||
_gix__tag__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix tag help list commands' commands "$@"
}
(( $+functions[_gix__tag__list_commands] )) ||
_gix__tag__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix tag list commands' commands "$@"
}
(( $+functions[_gix__tree_commands] )) ||
_gix__tree_commands() {
    local commands; commands=(
'entries:Print entries in a given tree' \
'info:Provide information about a tree' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix tree commands' commands "$@"
}
(( $+functions[_gix__tree__entries_commands] )) ||
_gix__tree__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix tree entries commands' commands "$@"
}
(( $+functions[_gix__tree__help_commands] )) ||
_gix__tree__help_commands() {
    local commands; commands=(
'entries:Print entries in a given tree' \
'info:Provide information about a tree' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix tree help commands' commands "$@"
}
(( $+functions[_gix__tree__help__entries_commands] )) ||
_gix__tree__help__entries_commands() {
    local commands; commands=()
    _describe -t commands 'gix tree help entries commands' commands "$@"
}
(( $+functions[_gix__tree__help__help_commands] )) ||
_gix__tree__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix tree help help commands' commands "$@"
}
(( $+functions[_gix__tree__help__info_commands] )) ||
_gix__tree__help__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix tree help info commands' commands "$@"
}
(( $+functions[_gix__tree__info_commands] )) ||
_gix__tree__info_commands() {
    local commands; commands=()
    _describe -t commands 'gix tree info commands' commands "$@"
}
(( $+functions[_gix__verify_commands] )) ||
_gix__verify_commands() {
    local commands; commands=()
    _describe -t commands 'gix verify commands' commands "$@"
}
(( $+functions[_gix__worktree_commands] )) ||
_gix__worktree_commands() {
    local commands; commands=(
'list:List all worktrees, along with some accompanying information' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix worktree commands' commands "$@"
}
(( $+functions[_gix__worktree__help_commands] )) ||
_gix__worktree__help_commands() {
    local commands; commands=(
'list:List all worktrees, along with some accompanying information' \
'help:Print this message or the help of the given subcommand(s)' \
    )
    _describe -t commands 'gix worktree help commands' commands "$@"
}
(( $+functions[_gix__worktree__help__help_commands] )) ||
_gix__worktree__help__help_commands() {
    local commands; commands=()
    _describe -t commands 'gix worktree help help commands' commands "$@"
}
(( $+functions[_gix__worktree__help__list_commands] )) ||
_gix__worktree__help__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix worktree help list commands' commands "$@"
}
(( $+functions[_gix__worktree__list_commands] )) ||
_gix__worktree__list_commands() {
    local commands; commands=()
    _describe -t commands 'gix worktree list commands' commands "$@"
}

if [ "$funcstack[1]" = "_gix" ]; then
    _gix "$@"
else
    compdef _gix gix
fi
