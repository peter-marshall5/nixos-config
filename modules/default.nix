{
  imports = [
    ./services/networking/duckdns.nix
    ./services/networking/upnp.nix
    ./services/minecraft.nix
    ./virtualisation/build-vm-systemd.nix
    ./virtualisation/vms.nix
  ];
}
