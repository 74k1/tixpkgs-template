{ config, lib, ... }:
{
  programs.hello.enable = true;

  assertions = [
    {
      assertion = lib.elem config.programs.hello.package config.home.packages;
      message = "programs.hello should add its package to home.packages.";
    }
  ];
}
