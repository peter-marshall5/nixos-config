{

  imports = [
    ./bridge
    ./networkmanager.nix
    ./upnp
  ];

  networking.firewall.enable = true;
  networking.nftables.enable = true;

}
