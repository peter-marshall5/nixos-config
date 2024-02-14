{ config, lib, ... }:
{

  options.ab.powerManagement.enable = lib.mkOption {
    default = false;
    type = lib.types.bool;
  };

  config = lib.mkIf config.ab.powerManagement.enable {

    # Improve scheduling power efficiency.
    boot.kernelParams = [ "workqueue.power_efficient=1" ];

    # GPU power saving options.
    environment.etc."modprobe.d/i915.conf".text = ''
      options i915 enable_psr=2 enable_psr2_sel_fetch=1 enable_fbc=1
    '';

    # Conflicts with TLP.
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
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 30;
      CPU_BOOST_ON_AC = 1;
      CPU_BOOST_ON_BAT = 0;
      CPU_HWP_DYN_BOOST_ON_AC = 1;
      CPU_HWP_DYN_BOOST_ON_BAT = 0;
    };

    # Handle power keys and lid switch in systemd-logind.
    services.logind = {
      powerKey = "suspend";
      powerKeyLongPress = "poweroff";
      lidSwitchExternalPower = "lock";
    };

  };

}
