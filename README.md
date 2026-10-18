<div align="left">
    <h3><samp>tixpkgs</samp> ❄️</h3>
    packages and modules for myself.
</div>

# About

This repository holds my personal Nix packages and my NixOS modules. It follows the usual nixpkgs structure. The packages and modules here are not in upstream nixpkgs, because they are things I wanted to use or test quickly.

Use this repository as a template for your own nixpkgs. Fork it, keep the structure, and add your own packages and modules. The flake finds them automatically. You do not need to edit `flake.nix` or any index file.

The production version lives at [github:74k1/tixpkgs](https://github.com/74k1/tixpkgs). My bot [bumpkin](https://github.com/74k1/bumpkin) keeps it up to date. If something is broken or missing, open an issue or a pull request. See [contributing](./CONTRIBUTING.md).

# Adding a package

A package is a directory with a `package.nix` file inside. The path is `pkgs/<XY>/<name>/package.nix`. `<name>` is the package name. `<XY>` is the first two letters of that name.

```
pkgs/he/hello/package.nix   # -> exposes package `hello`
```

```nix
# pkgs/he/hello/package.nix
{ lib, stdenv, ... }:

stdenv.mkDerivation {
  pname = "hello";
  version = "1.0.0";
  # ...
}
```

The flake exposes the package as `packages.<system>.hello`. The package is also on the default overlay. You can also put a single file at `pkgs/<XY>/<name>.nix` instead of a directory.

# Adding a module

Modules live in `modules/nixos/`. The folder path becomes the module name.

```
modules/nixos/services/hello/default.nix          # -> nixosModules."services/hello"
```

The flake exposes each module in two forms:

- `nixosModules."services/hello"`, flat, with a `/` in the name
- `nixosModules'.services.hello`, nested, like a normal attribute set

See [Modules](#modules) for how to import them.

A module can ask for extra arguments. The flake passes these arguments to any module that declares them:

- `inputs`: the flake inputs
- `tixpkgs`: the packages of this flake, for the current system

```nix
{ tixpkgs, ... }:
{
  options.services.hello.package = lib.mkPackageOption tixpkgs "hello" { };
}
```

# Examples

This repository ships a `hello` package and two `hello` modules, with tests. They are working examples. Build them to check your setup. Then delete or replace them.

Tests for your own modules follow the same layout. See [modules/tests/README.md](./modules/tests/README.md).

# Workflows

The `workflows/` directory holds GitHub Actions workflows. They are disabled. Copy the ones you want to `.github/workflows/` to enable them. See [workflows/README.md](./workflows/README.md).

# Usage

To use this flake in your own setup, include it as a flake input. Make sure that your `nixpkgs` input is `nixos-unstable`.

In your `flake.nix`:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    tixpkgs = {
      url = "github:74k1/tixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ...
  };
  outputs = {
    ...
  };
}
```

## Cachix

I publish build results to Cachix. You can use the cache:

`cachix use tixpkgs`

or add this to your configuration:

```nix
nix.settings = {
  substituters = ["https://tixpkgs.cachix.org"];
  trusted-public-keys = ["tixpkgs.cachix.org-1:Q52x6PMD7ZuTC7oRihwp5lP9YaEaYtrfxYkwzEpjSRI="];
}
```

# Modules

This flake exports modules in two forms:

- `nixosModules'`, nested, like a normal attribute set

<details>
  <summary>example</summary>

```nix
{
  nixosModules' = {
    services = {
      a = <NixOS module>;
      b = <NixOS module>;
    };
    programs = {
      c = <NixOS module>;
    };
  };
}
```
</details>

- `nixosModules`, flat, with a `/` in each name

<details>
  <summary>example</summary>

```nix
{
  nixosModules = {
    "services/a" = <NixOS module>;
    "services/b" = <NixOS module>;
    "programs/c" = <NixOS module>;
  };
}
```
</details>

## NixOS Modules

<!-- BEGIN NIXOS MODULES -->
| Module | Docs |
|---|---|
| `services.hello` | N/A |
<!-- END NIXOS MODULES -->

# Packages

Use a package with `inputs.tixpkgs.packages.${pkgs.stdenv.hostPlatform.system}.<name>`. A package is only available on systems that it builds for.

<!-- BEGIN PACKAGES -->
| Package | Version |
|---|---|
| `hello` | `1.0.0` |
<!-- END PACKAGES -->

---

> Some packages and modules may not be what you expect, and some may be very old. If I do not maintain something, it means I do not use it anymore. A pull request is welcome.
>
> Also see [Issues](https://github.com/74k1/tixpkgs/issues) and [Pull Requests](https://github.com/74k1/tixpkgs/pulls).
