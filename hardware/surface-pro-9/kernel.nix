{ lib
, baseKernel
, fetchFromGitHub
, linuxManualConfig
, ... }:

let

  linuxSurface = fetchFromGitHub {
    owner = "linux-surface";
    repo = "linux-surface";
    rev = "110ca0d301a08de61f54ee8339fb6477e2acc594";
    hash = "sha256-R3IhFpga+SAVEinrJPPtB+IGh9qdGQvWDBSDIOcMnbQ=";
  };

in linuxManualConfig {
  inherit (baseKernel) src modDirVersion;
  version = "${baseKernel.version}-surface-custom";
  configfile = ./surface-6.6.config;
  allowImportFromDerivation = true;
  kernelPatches = map (pname: {
    name = "linux-surface-${pname}";
    patch = (linuxSurface + "/patches/6.6/${pname}.patch");
  }) [
    "0004-ipts"
    "0005-ithc"
    "0009-surface-typecover"
    "0010-surface-shutdown"
    "0011-surface-gpe"
    "0014-rtc"
  ];
}
