{ lib
, callPackage
, baseKernel
, fetchFromGitHub
, linuxManualConfig
, ... }:

let
  surfacePatches = callPackage ./surface-patches.nix {};
  borePatches = callPackage ./bore-patches.nix {};
in linuxManualConfig {
  inherit (baseKernel) src modDirVersion;
  version = "${baseKernel.version}-surface-custom";
  configfile = ./surface-6.7.config;
  allowImportFromDerivation = true;
  kernelPatches = surfacePatches ++ borePatches;
}
