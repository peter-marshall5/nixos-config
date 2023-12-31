{ config, pkgs, ... }: {
  microvm.vms = {
    my-vm = {
      inherit pkgs;
      config = {
        microvm.hypervisor = "cloud-hypervisor";
        microvm.shares = [{
          source = "/nix/store";
          mountPoint = "/nix/.ro-store";
          tag = "ro-store";
          proto = "virtiofs";
        }];
        microvm.interfaces = [{
          type = "tap";
          id = "vm-test";
          mac = "02:00:00:00:00:01";
        }];
        networking.useNetworkd = true;
        systemd.network.enable = true;
        systemd.network.networks."20-lan" = {
          matchConfig.Type = "ether";
          networkConfig = {
            Address = ["192.168.1.3/24" "2001:db8::b/64"];
            Gateway = "192.168.1.1";
            DNS = ["192.168.1.1"];
            IPv6AcceptRA = true;
            DHCP = "no";
          };
        };
        system.stateVersion = "24.05";
      };
    };
  };
}
