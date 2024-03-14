{config, lib, ... }: {

  options.virtualisation.vms = lib.mkOption {
    default = [];
    type = lib.types.listOf lib.types.attrs;
  };

  config.systemd.services = builtins.listToAttrs (map (c: c.config.system.build.vm-systemd-unit) config.virtualisation.vms);

  # config.networking = let
  #   allowedTCPPorts = builtins.concatMap (c: c.config.networking.firewall.allowedTCPPorts) config.virtualisation.vms;
  #   allowedUDPPorts = builtins.concatMap (c: c.config.networking.firewall.allowedUDPPorts) config.virtualisation.vms; 
  # in {
  #   firewall = { inherit allowedTCPPorts allowedUDPPorts };
  # };

}
