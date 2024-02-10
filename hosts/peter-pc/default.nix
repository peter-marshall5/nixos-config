{
  system = "x86_64-linux";
  hardware = "surface-pro-9";
  desktop.enable = true;
  users = [ "petms" ];
  desktop.autologin.user = "petms";
  secureboot.enable = true;
  fs.fs = rec {
    root = {
      uuid = "f8a050ce-76d3-430a-a734-00bed678aeb6";
      luks.uuid = "990ec395-607a-4df8-b8a4-7680f27f4ecf";
    };
    home.uuid = root.uuid;
    nix.uuid = root.uuid;
    boot.uuid = "940E-785F";
  };
}
