{

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "build-battle";

  virtualisation.vmVariant.config = {
    networking.macAddress = "ba:2a:b8:b5:e3:71";
  };

  services.minecraft-bedrock-server = {
    enable = true;
    eula = true;
    serverName = " §k::§r §d§lBuild§r  §c§oBattle §k::§r ";
    levelName = "Build Battle v3";
    openFirewall = true;
  };

}
