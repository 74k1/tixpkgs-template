{
  lib,
  stdenv,
  ...
}:

stdenv.mkDerivation {
  pname = "hello";
  version = "1.0.0";

  src = null;
  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cat > $out/bin/hello <<'EOF'
    #!/bin/sh
    echo "Hello, world!"
    EOF
    chmod +x $out/bin/hello
  '';

  meta = with lib; {
    description = "A tiny example package that prints 'Hello, world!'";
    license = licenses.mit;
    mainProgram = "hello";
    platforms = platforms.all;
    maintainers = with maintainers; [ _74k1 ];
  };
}