{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-webhook-receiver;
in
{
  options = {
    seabird.services.seabird-webhook-receiver = {
      enable = lib.mkEnableOption "seabird-webhook-receiver";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-webhook-receiver;
      };

      secretFile = lib.mkOption {
        type = lib.types.path;
      };

      hosts = lib.mkOption {
        type = lib.types.listOf lib.types.str;
      };

      target = lib.mkOption {
        type = lib.types.str;
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3000;
        description = ''
          Port the receiver listens on, and the one Caddy proxies to. Not 8080:
          that belongs to seabird-core, which this service connects to.
        '';
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-webhook-receiver = {
      wantedBy = [ "multi-user.target" ];
      wants = [
        "network-online.target"
        "seabird-core.service"
      ];
      after = [
        "network-online.target"
        "seabird-core.service"
      ];
      startLimitIntervalSec = 0;
      restartTriggers = [ (builtins.hashFile "sha256" cfg.secretFile) ];
      environment = {
        # seabird-core, which this connects to as a client.
        SEABIRD_HOST = "http://localhost:8080";

        SEABIRD_BIND_HOST = "127.0.0.1:${toString cfg.port}";
        SEABIRD_CHANNEL = cfg.target;
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        ExecStart = "${cfg.package}/bin/seabird-webhook-receiver";
        EnvironmentFile = [
          config.age.secrets."seabird-webhook-receiver".path
        ];
      };
    };

    age.secrets."seabird-webhook-receiver".file = cfg.secretFile;

    seabird.caddy.virtualHosts.seabird-webhook-receiver = {
      inherit (cfg) hosts;

      backend = "http://localhost:${toString cfg.port}";
    };
  };
}
