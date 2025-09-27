command -v sccache &>/dev/null && export RUSTC_WRAPPER=sccache
command -v buildcache &>/dev/null && export BUILDCACHE_COMPRESS_FORMAT=ZSTD BUILDCACHE_DIRECT_MODE=true
command -v ccache &>/dev/null && export CCACHE_COMPRESS=true CCACHE_COMPRESSLEVEL=3 CCACHE_INODECACHE=true
