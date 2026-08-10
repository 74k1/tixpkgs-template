{ pkgs, tixpkgs, ... }:
pkgs.runCommand "hello-basic" { } ''
  ${tixpkgs.hello}/bin/hello | grep -Fx 'Hello, world!'
  touch $out
''
