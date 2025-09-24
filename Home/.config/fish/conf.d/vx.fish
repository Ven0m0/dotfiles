vx shell completions fish | source
vx shell init fish | source

uv python update-shell
uv venv

source "$HOME/.venv/bin/activate.fish"

vx install --force uv latest
vx install --force uvx latest
vx install --force cargo latest
vx install --force npm latest
vx install --force npx latest
vx install --force nodejs latest
vx install --force node latest
vx install --force go latest
vx install --force golang latest


