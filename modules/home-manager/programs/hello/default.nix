{ tixpkgs }:
{
  config,
  lib,
  ...
}:
let
  cfg = config.programs.hello;

  inherit (lib)
    mkEnableOption
    mkIf
    mkPackageOption
    ;
in
{
  options.programs.hello = {
    enable = mkEnableOption "hello world example program";

    package = mkPackageOption tixpkgs "hello" { };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };

  meta.maintainers = with lib.maintainers; [ _74k1 ];
}