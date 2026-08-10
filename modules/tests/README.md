# Module tests

This directory holds tests for the packages and modules of this flake. Each test becomes a check in `flake.nix`. You build a check with `nix build`.

## Layout

Tests are `.nix` files in these directories:

- `modules/tests/nixos/<category>/<module-path>/<test>.nix` for NixOS
- `modules/tests/home-manager/<module-path>/<test>.nix` for Home Manager

For NixOS, `<category>` is one of:

- `services`: tests for `services.*` modules
- `pkgs`: tests for packages that have no module

`<module-path>` matches the exported module name. For example, `modules/tests/nixos/services/hello/basic.nix` tests the module `nixosModules."services/hello"`.

## Check names

The check name comes from the file path. Dots and slashes become dashes. The name starts with `module-`:

```sh
nix build .#checks.x86_64-linux.module-nixos-services-hello-basic
nix build .#checks.x86_64-linux.module-home-manager-programs-hello-basic
```

The flake finds your test files automatically. You do not need to edit `modules/flake/checks.nix`.

## What a test file can return

A NixOS test file can return:

- a normal attribute set for `pkgs.testers.runNixOSTest`
- a derivation, for a custom test

A Home Manager test file can return:

- a Home Manager module
- a list of modules
- `{ modules = [ ... ]; }`
- a derivation, for a custom test

For Home Manager tests, the harness wraps your modules in a fixed test configuration. The user is `hm-test` with home `/home/hm-test`.

## Example

This NixOS test enables the `services.hello` module and checks the service log:

```nix
{ module, ... }:
{
  name = "hello-nixos";

  nodes.machine = {
    imports = [ module ];

    services.hello.enable = true;
  };

  testScript = ''
    start_all()

    machine.wait_for_unit("hello.service")
    machine.succeed("journalctl -u hello.service | grep -F 'Hello, world!'")
  '';
}
```

The harness passes the `module` argument to your test file. It is the module under test.
