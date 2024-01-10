{ config, lib, pkgs, ...}:

let

  linuxSurface = pkgs.fetchFromGitHub {
    owner = "linux-surface";
    repo = "linux-surface";
    rev = "110ca0d301a08de61f54ee8339fb6477e2acc594";
    hash = "sha256-R3IhFpga+SAVEinrJPPtB+IGh9qdGQvWDBSDIOcMnbQ=";
  };

in
{

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];

  boot.initrd.kernelModules = [ "surface_aggregator" "surface_aggregator_registry" "surface_aggregator_hub" "surface_hid_core" "8250_dw" "surface_hid" "intel_lpss" "intel_lpss_pci" "pinctrl_tigerlake" ];

  boot.kernelModules = [ "kvm-intel" ];

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  services.thermald.enable = true;

  # Currently broken in unstable, see https://github.com/NixOS/nixpkgs/pull/268618
  #hardware.ipu6.enable = true;
  #hardware.ipu6.platform = "ipu6ep";

  # linux-surface kernel
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_6_6;
  boot.kernelPatches = [ {
    name = "linux-surface-config";
    patch = null;
    extraConfig = lib.replaceStrings [ "CONFIG_" "=" ] [ "" " " ] (lib.readFile
      ./surface-6.6.config
    );
  } ] ++ map (pname: {
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

  environment.systemPackages = with pkgs; [
    surface-control
  ];
  services.udev.packages = [
    pkgs.iptsd
    pkgs.surface-control
  ];
  systemd.packages = [
    pkgs.iptsd
  ];

  nixpkgs.overlays = [
    (self: super: {
      libwacom = self.callPackage (self.path + "/pkgs/development/libraries/libwacom/surface.nix") {
        inherit (super) libwacom;
      };
    })
  ];

}
