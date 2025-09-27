if command -v pypy3 &>/dev/null; then
  export PYTHON_DISABLE_REMOTE_DEBUG=1 
  unset PYPY_DISABLE_JIT PYPYLOG
fi
if command -v python3 &>/dev/null; then
  export PYTHONOPTIMIZE=2 PYTHONIOENCODING='UTF-8' PYTHON_JIT=1 PYTORCH_ENABLE_MPS_FALLBACK=1
fi
  
