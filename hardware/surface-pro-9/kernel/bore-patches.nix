{ fetchFromGitHub, ... }:
let
  borePatches = fetchFromGitHub {
    owner = "firelzrd";
    repo = "bore-scheduler";
    rev = "34cb409b3959a43eebbfbf2fa0f0e7836adfa713";
    hash = "sha256-C8T1KInK25qeB7ODGINUkbbf0jzcsSpEynNKCz2CsoU=";
  };
in [rec {
  name = "0001-linux6.7.y-bore4.2.0";
  patch = (borePatches + "/patches/linux-6.7-bore/${name}.patch");
}]
