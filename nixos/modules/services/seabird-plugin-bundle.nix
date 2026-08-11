{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.seabird.services.seabird-plugin-bundle;
in
{
  options = {
    seabird.services.seabird-plugin-bundle = {
      enable = lib.mkEnableOption "seabird-plugin-bundle";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-plugin-bundle;
      };

      enabledPlugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
      disabledPlugins = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-plugin-bundle = {
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      environment = {
        DATABASE_URL = "sqlite:///var/lib/seabird-plugin-bundle/seabird-plugin-bundle.db";
        SEABIRD_HOST = "http://localhost:8080";
        SEABIRD_ENABLED_PLUGINS = lib.concatStringsSep "," cfg.enabledPlugins;
        SEABIRD_DISABLED_PLUGINS = lib.concatStringsSep "," cfg.disabledPlugins;
      };

      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        ExecStart = "${cfg.package}/bin/seabird-plugin-bundle";
        EnvironmentFile = [
          config.age.secrets."seabird-plugin-bundle".path
        ];
        StateDirectory = "seabird-plugin-bundle";
      };
    };

    age.secrets.seabird-plugin-bundle.file = ../../../secrets/seabird-plugin-bundle.age;
  };
}
