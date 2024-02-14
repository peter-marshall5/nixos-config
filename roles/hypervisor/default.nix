{ lib, ... }: {

  imports = [ ./vms ./services.nix ];

  # Allow remote management.
  ab.ssh.enable = true;

  # Enable secure boot.
  ab.secureboot.enable = lib.mkDefault true;

  # Enable disk encryption.
  ab.fs.luks.enable = lib.mkDefault true;

}
