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
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-discord-backend = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        SEABIRD_HOST = "http://localhost:8080";
      };

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-discord-backend}/bin/seabird-discord-backend";
        EnvironmentFile = [
          config.age.secrets."seabird-discord-backend".path
        ];
      };
    };

    age.secrets.seabird-discord-backend.file = ../../../secrets/seabird-discord-backend.age;
  };
}
