# opencode-vhdl

Environnement de développement VHDL avec GHDL, GTKWave et support FPGA, géré via [devenv](https://devenv.sh) + Nix.

## Prérequis

- [Nix](https://nixos.org/download) avec flakes activés

## Installation

```bash
devenv shell
```

## Utilisation

### Analyse (lint)

```bash
ghdl -a --std=08 src/mon_module.vhd
```

### Simulation

```bash
ghdl -a --std=08 src/*.vhd tb/mon_module_tb.vhd
ghdl -e --std=08 mon_module_tb
ghdl -r --std=08 mon_module_tb
```

Avec forme d'onde :

```bash
ghdl -r --std=08 mon_module_tb --wave=wave.ghw
gtkwave wave.ghw
```

## Structure

```
src/       — Sources RTL (entités, architectures, packages)
tb/        — Bancs de test
sim/       — Scripts de simulation alternatifs
```

## Conventions

Les conventions de code (nommage, style d'import, motifs de processus, etc.) sont documentées dans [AGENTS.md](./AGENTS.md).
