# `Dotfiles`

<details>
<summary><b>Features</b></summary>

- [Auto optimized media](.github/workflows/image-optimizer.yml)
- [Auto validated config files](.github/workflows/config-validate.yml)
- [Auto shell check](.github/workflows/shellcheck.yml)
- [Auto updated submodules](.github/workflows/update-git-submodules.yml)

</details>
<details>
<summary><b>Dotfile managers</b></summary>

- <https://github.com/Shemnei/punktf>
- <https://github.com/woterr/dotpush>
- <https://github.com/joel-porquet/dotlink>
- <https://github.com/dotphiles/dotsync>
- <https://github.com/ellipsis/ellipsis>
- <https://github.com/SuperCuber/dotter>
- <https://github.com/alichtman/shallow-backup>
- <https://github.com/rossmacarthur/sheldon>
- <https://github.com/bevry/dorothy>
- <https://github.com/yadm-dev/yadm>
- <https://codeberg.org/IamPyu/huismanager>

</details>
<details>
<summary><b>Arch scripts</b></summary>

```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Updates.sh | bash
```
```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Clean.sh | bash
```
```bash
curl -fsSL https://raw.githubusercontent.com/Ven0m0/Linux-OS/refs/heads/main/Cachyos/Rank.sh | bash
```

</details>
<details>
<summary><b>Useful Stuff</b></summary>

- <https://dotfiles.github.io/>
- <https://terminal.sexy/>
- <https://wiki.archlinux.org/title/Git>

</details>
<details>
<summary><b>Packages:</b></summary>

- [Arch PKG](https://archlinux.org/packages)

- [AUR PKG](https://aur.archlinux.org)

- [Crates.io](https://crates.io)

- [FlatHub](https://flathub.org)

- [Lure.sh](https://lure.sh)

- [Basher](https://www.basher.it/package)

- [bpkg](https://bpkg.sh)

- [x-cmd](https://www.x-cmd.com)
  <details>
  <summary><b>Install x-cmd</b></summary>

  bash:
  ```bash
  eval "$(curl -s https://get.x-cmd.com)"
  ```
  fish:
  ```sh
  curl -s https://get.x-cmd.com | sh; chmod +x $HOME/.x-cmd.root/bin/x-cmd && ./$HOME/.x-cmd.root/bin/x-cmd fish --setup
  ```

    </details>
</details>
<details>
<summary><b>Supported Linux Distributions</b></summary>

[CachyOS](https://cachyos.org) specifically, but really any arch based distro is compatible

For debian see: [Debian dotfiles](https://github.com/Ven0m0/dotfiles-pi)

- [DietPi](https://dietpi.com/)
- [Raspberry Pi OS](https://www.raspberrypi.com/software)

</details>

- [Libredirect](https://libredirect.github.io)
- [alternative-front-ends](https://github.com/mendel5/alternative-front-ends)
- [Privacy-tools](https://www.privacytools.io)
- [Redlib instance list](https://github.com/redlib-org/redlib-instances/blob/main/instances.md)
- [Redlib reddit](https://lr.ptr.moe)
- [Imgur](https://rimgo.lunar.icu)

### `Search engines`

- [DuckduckGo](https://duckduckgo.com)
- [Searchxng](https://searx.dresden.network/) &nbsp;[Instances](https://searx.space)
- [Brave search](https://search.brave.com)


### ***Quick prompts***

**Lint / Format:**
```markdown
Lint and format exhaustively per editorconfig:
- YAML: yamlfmt, yamllint
- JSON/CSS/JS: biome, eslint, prettier, minify
- HTML: biome, minify
- XML: minify
- Bash/Zsh: shfmt, shellcheck, shellharden
- Fish: fish_indent
- TOML: taplo-cli, tombi
- Markdown: mado, markdownlint, mdformat
- Actions: actionlint, yamlfmt, yamllint
- Python: ruff, black
- Javascript: uglify-js, biome, eslint, prettier
- All extensions: ast-grep, ripgrep, find
  Enforce logic, syntax, types, security. Zero errors. Prefer 2 space indentation
```

**TODO:**
```markdown
Fix a small todo, search for a TODO comment or file and fix and/or integrate it.
```
