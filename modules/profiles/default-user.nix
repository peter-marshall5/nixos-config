{

  users.users.petms = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" ];
    openssh.authorizedKeys.keys = (import ../../cfg/ssh/trusted-keys.nix);
  };

}
