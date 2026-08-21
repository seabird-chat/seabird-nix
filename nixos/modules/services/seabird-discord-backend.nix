{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.seabird.services.seabird-discord-backend;
in
{
  options = {
    seabird.services.seabird-discord-backend = {
      enable = lib.mkEnableOption "seabird-discord-backend";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-discord-backend;
      };

      secretFile = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-discord-backend = {
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
        SEABIRD_HOST = "http://localhost:8080";
      };

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        ExecStart = "${cfg.package}/bin/seabird-discord-backend";
        EnvironmentFile = [
          config.age.secrets."seabird-discord-backend".path
        ];
      };
    };

    age.secrets.seabird-discord-backend.file = cfg.secretFile;
  };
}
