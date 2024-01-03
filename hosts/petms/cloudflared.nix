{ config, lib, pkgs, ... }: {

  environment.systemPackages = with pkgs; [ cloudflared ];

  age.secrets.tunnel-petms = {
    file = ./secrets/tunnel-petms.age;
    owner = config.services.cloudflared.user;
    group = config.services.cloudflared.group;
  };

  services.cloudflared = {
    enable = true;
    tunnels = {
      "ada56c81-89c9-403b-8d18-c20c39ab973c" = {
        credentialsFile = config.age.secrets.tunnel-petms.path;

        ingress = {
          "ssh-petms.opcc.tk" = {
            service = "ssh://localhost:22";
          };
        };

        default = "http_status:404";
      };
    };
  };

  services.openssh.settings.Macs = [ "hmac-sha2-512" ];
}
