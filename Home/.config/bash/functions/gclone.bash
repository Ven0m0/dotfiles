# Optimized git clone with shallow cloning and HTTP/2
gclone() {
  if command -v gix &>/dev/null; then
    LC_ALL=C gix clone --depth 1 --no-tags \
      -c protocol.version=2 \
      -c http.sslVersion=tlsv1.3 \
      -c http.version=HTTP/2 \
      "$@"
  else
    LC_ALL=C git clone --depth 1 --no-tags --filter=blob:none \
      -c protocol.version=2 \
      -c http.sslVersion=tlsv1.3 \
      -c http.version=HTTP/2 \
      "$@"
  fi
}
