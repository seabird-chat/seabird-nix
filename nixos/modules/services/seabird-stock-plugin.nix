{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-stock-plugin;
in
{
  options = {
    seabird.services.seabird-stock-plugin = {
      enable = lib.mkEnableOption "seabird-stock-plugin";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-stock-plugin = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      environment = {
        SEABIRD_HOST = "http://localhost:8080";
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${pkgs.seabird.seabird-stock-plugin}/bin/seabird-stock-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-stock-plugin".path
        ];
      };
    };

    age.secrets."seabird-stock-plugin".file = ../../../secrets + "/seabird-stock-plugin.age";
  };
}
