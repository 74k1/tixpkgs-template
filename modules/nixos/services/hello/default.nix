{ tixpkgs }:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.hello;

  inherit (lib)
    getExe
    mkEnableOption
    mkIf
    mkPackageOption
    ;
in
{
  options.services.hello = {
    enable = mkEnableOption "hello world example service";

    package = mkPackageOption tixpkgs "hello" { };
  };

  config = mkIf cfg.enable {
    systemd.services.hello = {
      description = "Hello world example service";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = getExe cfg.package;
        RemainAfterExit = true;
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ _74k1 ];
}