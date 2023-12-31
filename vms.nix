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
        hardware.opengl.enable = false;
        system.stateVersion = "24.05";
      };
    };
  };
}
