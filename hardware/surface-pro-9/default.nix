{ config, lib, pkgs, modulesPath, ... }:

{

  nixpkgs.hostPlatform = "x86_64-linux";

  imports = [ ./sound ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];

  boot.initrd.kernelModules = [ "nvme" "xhci_pci" "hid_generic" "atkbd" "surface_aggregator" "surface_aggregator_registry" "surface_aggregator_hub" "surface_hid_core" "8250_dw" "surface_hid" "intel_lpss" "intel_lpss_pci" "pinctrl_tigerlake" "usbhid" ];

  boot.kernelModules = [ "kvm-intel" ];

  boot.swraid.enable = lib.mkForce false;

  boot.initrd.luks.cryptoModules = [ "aes" "aes_generic" "cbc" "sha1" "sha256" "sha512" "af_alg" ];
  boot.initrd.includeDefaultModules = false;

  hardware.enableRedistributableFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;

  services.thermald.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # IPU6 camera drivers. This doesn't work yet and causes weird issues
  # hardware.ipu6.enable = true;
  # hardware.ipu6.platform = "ipu6ep";

  # linux-surface kernel
  boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./kernel {
    baseKernel = pkgs.linux_latest;
  });

  environment.systemPackages = with pkgs; [
    surface-control
  ];

  services.iptsd.enable = true;
  services.iptsd.config = {
    Touch = {
      DisableOnPalm = true;
      DisableOnStylus = true;
    };
    Stylus = {
      TipDistance = 0.04;
    };
  };

  boot.kernelParams = [ "workqueue.power_efficient=1" "i915.enable_psr=2" "i915.enable_psr2_sel_fetch=1" "i915.enable_fbc=1" ];
  
  services.power-profiles-daemon.enable = false;

  services.tlp.enable = true;
  services.tlp.settings = {
    PCIE_ASPM_ON_BAT = "powersupersave";
    SOUND_POWER_SAVE_CONTROLLER = false;
    PLATFORM_PROFILE_ON_AC = "balanced";
    PLATFORM_PROFILE_ON_BAT = "low-power";
    RUNTIME_PM_ON_AC = "auto";
    RUNTIME_PM_ON_BAT = "auto";
    CPU_SCALING_GOVERNOR_ON_AC = "powersave";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;
    CPU_MIN_PERF_ON_AC = 10;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MIN_PERF_ON_BAT = 10;
    CPU_MAX_PERF_ON_BAT = 30;
    INTEL_GPU_MIN_FREQ_ON_AC = 100;
    INTEL_GPU_MIN_FREQ_ON_BAT = 100;
    INTEL_GPU_MAX_FREQ_ON_AC = 1200;
    INTEL_GPU_MAX_FREQ_ON_BAT = 200;
    INTEL_GPU_BOOST_FREQ_ON_AC = 1200;
    INTEL_GPU_BOOST_FREQ_ON_BAT = 300;
  };

}
