{
  self,
  inputs,
  lib,
  pkgs,
  system,
}:
let
  testsRoot = ../tests;

  testFiles =
    kind:
    let
      dir = testsRoot + "/${kind}";
    in
    if builtins.pathExists dir then
      builtins.filter (lib.hasSuffix ".nix") (lib.filesystem.listFilesRecursive dir)
    else
      [ ];

  testInfo =
    kind: file:
    let
      parts = lib.path.subpath.components (lib.path.removePrefix (testsRoot + "/${kind}") file);
      testName = lib.removeSuffix ".nix" (lib.last parts);
      moduleParts = lib.init parts;
      moduleName = lib.concatStringsSep "/" moduleParts;
      moduleSet = self.nixosModules;
    in
    {
      inherit moduleName testName;
      checkName = "module-${kind}-${lib.concatStringsSep "-" (moduleParts ++ [ testName ])}";
      module = moduleSet.${moduleName} or null;
      imported = import file;
    };

  commonArgNames = [
    "checkName"
    "inputs"
    "lib"
    "module"
    "moduleName"
    "pkgs"
    "self"
    "system"
    "testName"
    "tixpkgs"
  ];

  callTest =
    info:
    let
      imported = info.imported;
      functionArgs = if lib.isFunction imported then builtins.functionArgs imported else { };
      isModuleFunction = builtins.hasAttr "config" functionArgs;
      isTestFunction = lib.any (arg: builtins.hasAttr arg functionArgs) commonArgNames;
    in
    if lib.isFunction imported && isTestFunction && !isModuleFunction then
      imported {
        inherit
          inputs
          lib
          pkgs
          self
          system
          ;
        inherit (info)
          checkName
          module
          moduleName
          testName
          ;
        tixpkgs = self.packages.${system};
      }
    else
      imported;

  mkNixosCheck =
    info:
    let
      value = callTest info;
    in
    if lib.isDerivation value then
      value
    else
      pkgs.testers.runNixOSTest (value // { name = value.name or info.checkName; });

  mkChecksFor =
    kind: mkCheck:
    lib.listToAttrs (
      map (
        file:
        let
          info = testInfo kind file;
        in
        lib.nameValuePair info.checkName (mkCheck info)
      ) (testFiles kind)
    );
in
mkChecksFor "nixos" mkNixosCheck
