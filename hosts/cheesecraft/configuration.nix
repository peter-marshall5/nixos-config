{

  nixpkgs.hostPlatform = "x86_64-linux";

  networking.hostName = "cheesecraft";

  virtualisation.vmVariant.config = {
    networking.macAddress = "86:8f:b3:38:dc:a3";
  };

  services.minecraft-bedrock-server = {
    enable = true;
    eula = true;
    serverName = "§k::§r §eCheese§bcraft§f - §aSurvival§r §k::§r ";
    levelName = "Cheesecraft Season 4";
    port = 19132;
    openFirewall = true;
  };

}
