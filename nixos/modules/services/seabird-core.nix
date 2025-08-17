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
      domain = lib.mkOption {
        type = lib.types.str;
        default = "api.seabird.chat";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-core = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        DATABASE_URL = "sqlite:///var/lib/seabird-core/seabird-core.db";
        SEABIRD_BIND_HOST = "127.0.0.1:8080";
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-core}/bin/seabird-core";
        StateDirectory = "seabird-core";
      };
    };

    seabird.haproxy.backends.seabird-core = {
      servers.seabird-core = "localhost:8080";
      matchers = [
        "if { req.hdr(host) -i api.seabird.chat }"
      ];
    };
  };
}
