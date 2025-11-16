{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-datadog-plugin;
in
{
  options = {
    seabird.services.seabird-datadog-plugin = {
      enable = lib.mkEnableOption "seabird-datadog-plugin";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-datadog-plugin = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        SEABIRD_HOST = "http://localhost:8080";
        DOGSTATSD_ENDPOINT = "localhost:8125";
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-datadog-plugin}/bin/seabird-datadog-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-datadog-plugin".path
        ];
      };
    };

    age.secrets."seabird-datadog-plugin".file = ../../../secrets + "/seabird-datadog-plugin.age";
  };
}
