{ config, lib, ... }:

{

  # Enable the OpenSSH daemon.
  services.openssh.enable = lib.mkDefault true;
  services.openssh.banner = builtins.readFile ./banner.txt;

  # Require both public key and password to log in via ssh.
  services.openssh = {
    settings.PasswordAuthentication = lib.mkForce true;
    settings.AuthenticationMethods = "publickey,password";
  };

}
