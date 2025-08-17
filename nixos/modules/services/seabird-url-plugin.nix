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
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-url-plugin = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        SEABIRD_HOST = "http://localhost:8080";
        IGNORED_BACKENDS = "discord,minecraft";
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-url-plugin}/bin/seabird-url-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-url-plugin".path
        ];
      };
    };

    age.secrets."seabird-url-plugin".file = ../../../secrets + "/seabird-url-plugin.age";
  };
}
