{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-url-plugin;
in
{
  options = {
    seabird.services.seabird-url-plugin = {
      enable = lib.mkEnableOption "seabird-url-plugin";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-url-plugin;
      };

      secretFile = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-url-plugin = {
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
        IGNORED_BACKENDS = "discord,minecraft";
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        ExecStart = "${cfg.package}/bin/seabird-url-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-url-plugin".path
        ];
      };
    };

    age.secrets."seabird-url-plugin".file = cfg.secretFile;
  };
}
