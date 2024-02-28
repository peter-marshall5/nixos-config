{ lib, stdenv, ... }:
stdenv.mkDerivation {
  pname = "sp9-custom-edid";
  version = "1";

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    install -Dm644 ${./edid.bin} ${placeholder "out"}/lib/firmware/edid/edid.bin
  '';
}
