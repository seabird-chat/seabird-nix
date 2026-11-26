{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-proxy-plugin;
in
{
  options = {
    seabird.services.seabird-proxy-plugin = {
      enable = lib.mkEnableOption "seabird-proxy-plugin";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-proxy-plugin;
      };

      secretFile = lib.mkOption {
        type = lib.types.path;
      };
      # Each group is proxied to each other. IDs don't say which backend a
      # channel is on, so each one is given with its backend's type, which
      # decides how usernames are shown there.
      channelGroups = lib.mkOption {
        type = lib.types.listOf (
          lib.types.listOf (
            lib.types.submodule {
              options = {
                type = lib.mkOption {
                  type = lib.types.enum [
                    "archipelago"
                    "discord"
                    "irc"
                    "minecraft"
                  ];
                };
                id = lib.mkOption {
                  type = lib.types.str;
                };
              };
            }
          )
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-proxy-plugin =
      let
        formatForType =
          type:
          {
            archipelago = "Archipelago";
            discord = "Discord";
            irc = "IRC";
            minecraft = "Minecraft";
          }
          ."${type}";
        lookupUserStyle =
          format:
          {
            Archipelago = [ ];
            Discord = [ "bold" ];
            IRC = [ "bold" ];
            Minecraft = [ ];
          }
          ."${format}";
        lookupUserSuffix =
          format: name:
          {
            Archipelago = " (${name})";
            Discord = " (${name})";
            IRC = "[${name}]";
            Minecraft = " (${name})";
          }
          ."${format}";
        channelConfig = builtins.filter (x: x.source != x.target) (
          builtins.concatLists (
            map (
              f:
              lib.mapCartesianProduct
                (
                  { source, target }:
                  let
                    targetFormat = formatForType target.type;
                    sourceFormat = formatForType source.type;
                  in
                  {
                    source = source.id;
                    target = target.id;
                    user_style = lookupUserStyle targetFormat;
                    user_suffix = lookupUserSuffix targetFormat sourceFormat;
                  }
                )
                {
                  source = f;
                  target = f;
                }
            ) cfg.channelGroups
          )
        );
        configFile = pkgs.writeText "seabird-proxy.json" (
          builtins.toJSON { proxied_channels = channelConfig; }
        );
      in
      {
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
          PROXY_CONFIG_FILE = "${configFile}";
        };
        serviceConfig = {
          DynamicUser = true;
          Restart = "always";
          RestartSec = 5;
          ExecStart = "${cfg.package}/bin/seabird-proxy-plugin";
          EnvironmentFile = [
            config.age.secrets."seabird-proxy-plugin".path
          ];
        };
      };

    age.secrets."seabird-proxy-plugin".file = cfg.secretFile;
  };
}
