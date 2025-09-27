if command -v uv &>/dev/null; then
  export UV_CONCURRENT_BUILDS=$(nproc) UV_CONCURRENT_INSTALLS=$(nproc)
  export UV_CONCURRENT_DOWNLOADS=$(( $(nproc) / 2 ))
  export UV_NO_VERIFY_HASHES=1 UV_LINK_MODE=hardlink UV_COMPILE_BYTECODE=1
  export UV_SYSTEM_PYTHON=1 UV_BREAK_SYSTEM_PACKAGES=0 UV_TORCH_BACKEND=auto
  export UV_FORK_STRATEGY=fewest UV_RESOLUTION=highest UV_PRERELEASE="if-necessary-or-explicit"
fi
