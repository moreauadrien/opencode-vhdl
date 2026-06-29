# 1. Installer WSL
```bash
wsl --install
```

# 2. Installer Nix
```bash
sh <(curl -L https://nixos.org/nix/install) --no-daemon
```

# 3. Installer devenv
```bash
nix-env --install --attr devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable
```

# 4. Cloner le projet et entrer dans l'environnement
```bash
git clone https://github.com/moreauadrien/opencode-vhdl
cd opencode-vhdl
devenv shell
```

# 4. (bis) Cloner le projet dans le répertoire local et entrer dans l'environnement
```bash
git clone https://github.com/moreauadrien/opencode-vhdl .
devenv shell
```
