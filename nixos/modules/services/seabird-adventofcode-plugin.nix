{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.seabird.services.seabird-adventofcode-plugin;
in
{
  options = {
    seabird.services.seabird-adventofcode-plugin = {
      enable = lib.mkEnableOption "seabird-adventofcode-plugin";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-adventofcode-plugin = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        TIMESTAMP_FILE = "/var/lib/seabird-adventofcode-plugin/aoc_timestamp.txt";
        SEABIRD_HOST = "http://localhost:8080";
      };

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-adventofcode-plugin}/bin/seabird-adventofcode-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-adventofcode-plugin".path
        ];
        StateDirectory = "seabird-adventofcode-plugin";
      };
    };

    age.secrets.seabird-adventofcode-plugin.file = ../../../secrets/seabird-adventofcode-plugin.age;
  };
}
