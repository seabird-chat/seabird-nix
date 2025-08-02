{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.seabird.services.seabird-core;
in
{
  options = {
    seabird.services.seabird-core = {
      enable = lib.mkEnableOption "seabird-core";
      tag = lib.mkOption {
        default = "0.3.2";
        type = lib.types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers.containers.seabird-core = {
      image = "ghcr.io/seabird-chat/seabird-core:${cfg.tag}";
      environment = {
        DATABASE_URL = "sqlite:///data/seabird-core.db";
      };
      volumes = [
        "/var/lib/seabird-core:/data"
      ];
      ports = [
        "127.0.0.1:8080:11235"
      ];
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/seabird-core 0755 root root -"
    ];
  };
}
