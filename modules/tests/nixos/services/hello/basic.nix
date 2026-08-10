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
