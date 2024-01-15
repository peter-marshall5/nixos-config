{ lib
, baseKernel
, fetchFromGitHub
, linuxManualConfig
, ... }:

let

  linuxSurface = fetchFromGitHub {
    owner = "linux-surface";
    repo = "linux-surface";
    rev = "807d0d92087aa1de0f5d8fef5881273307ab7cab";
    hash = "sha256-cYLkAMYaZyThaSedDVU1PLfq8n1liHSp5qSUM48ER9U=";
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
