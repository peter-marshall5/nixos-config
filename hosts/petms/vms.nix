{ config, pkgs, ... }: {
  microvm.vms = {
    test = {
      inherit pkgs;
      config = {
        microvm.hypervisor = "firecracker";
        microvm.interfaces = [{
          type = "tap";
          id = "vm-test";
          mac = "02:00:00:00:00:01";
        }];
        networking.hostName = "test";
        networking.useNetworkd = true;
        systemd.network.enable = true;
        systemd.network.networks."20-lan" = {
          matchConfig.Type = "ether";
          networkConfig = {
            IPv6AcceptRA = true;
            DHCP = "ipv4";
          };
        };
        system.stateVersion = "24.05";
      };
    };
  };
}
