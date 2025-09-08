# Dotfiles

My highly opinionated dotfiles

**Features**

- [Auto optimized media](.github/workflows/image-optimizer.yml)

- [Auto validated config files](.github/workflows/config-validate.yml)

- [Auto shell check](.github/workflows/shellcheck.yml)

- [Auto updated submodules](.github/workflows/update-git-submopdules.yml)

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
<summary><b>Nano sytax hilighting</b></summary>

https://github.com/scopatz/nanorc
```bash
curl -fsSL https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | sh -s -- -l
```
</details>
<details>
<summary><b>Packages:</b></summary>

* [Arch PKG](https://archlinux.org/packages)
* [AUR PKG](https://aur.archlinux.org)
* [Crates.io](https://crates.io)
* [FlatHub](https://flathub.org)
* [Lure.sh](https://lure.sh)
* [Basher](https://www.basher.it/package)
* [bpkg](https://bpkg.sh)

* [x-cmd](https://www.x-cmd.com)
  <details>
  <summary><b>Install x-cmd</b></summary>

  ```bash
  eval "$(curl https://get.x-cmd.com)"
  ```
  fish
  ```sh
  curl https://get.x-cmd.com | sh
  chmod +x $HOME/.x-cmd.root/bin/x-cmd && ./$HOME/.x-cmd.root/bin/x-cmd fish --setup
  ```
  </details>
</details>

## Supported Linux Distributions

[CachyOS](https://cachyos.org) specifically, but really any arch based distro is compatible

For debian see: [Debian dotfiles](https://github.com/Ven0m0/dotfiles-pi)

* [DietPi](https://dietpi.com/)
* [Raspberry Pi OS](https://www.raspberrypi.com/software)
