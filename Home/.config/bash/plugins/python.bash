# Python settings (main config in bashenv.env)
export PYTHONOPTIMIZE=2 PYTHONIOENCODING='UTF-8' PYTHON_JIT=1 PYTHON_DISABLE_REMOTE_DEBUG=1 PYTORCH_ENABLE_MPS_FALLBACK=1 PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Use uv for pip operations when available
pip(){
  if has uv && [[ "install uninstall list show freeze check" =~ "$1" ]]; then
    command uv pip "$@"
  else
    command python -m pip "$@"
  fi
}
