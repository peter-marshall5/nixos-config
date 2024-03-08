{

  users.users.petms = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = (import ../../cfg/ssh/trusted-keys.nix);
  };

}
