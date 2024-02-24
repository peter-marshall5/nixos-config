{ config, ... }: {

  imports = [ ../../../modules/profiles/headless-qemu-vm.nix ];

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "petms";
  networking.domain = "duckdns.org";

  virtualisation = {
    memorySize = 2048;
    cores = 2;
    diskSize = 102400;
  };

  networking.interfaces.eth0.macAddress = "0e:a8:8e:d5:10:f0";

  time.timeZone = "America/Toronto";

}
