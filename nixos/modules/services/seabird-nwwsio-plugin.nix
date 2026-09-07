{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-nwwsio-plugin;
in
{
  options = {
    seabird.services.seabird-nwwsio-plugin = {
      enable = lib.mkEnableOption "seabird-nwwsio-plugin";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-nwwsio-plugin;
      };

      secretFile = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-nwwsio-plugin = {
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
        SUBSCRIPTION_FILE = "/var/lib/seabird-nwwsio-plugin/subscriptions.json";
      };

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        ExecStart = "${cfg.package}/bin/seabird-nwwsio-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-nwwsio-plugin".path
        ];
        StateDirectory = "seabird-nwwsio-plugin";
      };
    };

    age.secrets."seabird-nwwsio-plugin".file = cfg.secretFile;
  };
}
