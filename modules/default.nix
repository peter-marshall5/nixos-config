{ config, lib, pkgs, modulesPath, ... }: {

  imports = [
    (modulesPath + "/profiles/minimal.nix")
    ./services/networking/duckdns.nix
    ./services/networking/upnp.nix
    ./services/minecraft.nix
    ./virtualisation/nixos-microvms.nix
  ];

  # Better system defaults

  config = lib.mkDefault {

    boot.initrd.systemd.enable = true;

    boot.loader.grub.enable = false;
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelPackages = pkgs.linuxPackages_latest;

    networking.useNetworkd = true;
    systemd.network.enable = true;

    services.resolved.enable = true;

    services.openssh = {
      settings.PasswordAuthentication = false;
    };

    networking.nftables.enable = true;

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    virtualisation.vmVariant = import ./virtualisation/vm-config.nix;

  };

}
