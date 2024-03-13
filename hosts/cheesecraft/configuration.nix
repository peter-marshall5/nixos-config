{

  nixpkgs.hostPlatform = "x86_64-linux";

  virtualisation.vmVariant.config = {
    virtualisation.memorySize = 1024;
  };

  services.upnpc.enable = true;

  # Mutable /etc is required by podman
  system.etc.overlay.mutable = true;
  users.mutableUsers = true;

  services.minecraft-bedrock-server = {
    enable = true;
    eula = true;
    serverName = "§k::§r §eCheese§bcraft§f - §aSurvival§r §k::§r ";
    levelName = "Cheesecraft Season 4";
  };

}
