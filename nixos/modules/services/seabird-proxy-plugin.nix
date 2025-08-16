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
      channelGroups = lib.mkOption {
        type = lib.types.listOf (
          lib.types.listOf (
            lib.types.submodule {
              options = {
                id = lib.mkOption {
                  type = lib.types.str;
                };
                name = lib.mkOption {
                  type = lib.types.str;
                };
                format = lib.mkOption {
                  type = lib.types.enum [
                    "discord"
                    "irc"
                    "minecraft"
                  ];
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
        lookupUserPrefix =
          format: name:
          {
            discord = "**";
            irc = "\\u0002";
            minecraft = "";
          }
          ."${format}";
        lookupUserSuffix =
          format: name:
          {
            discord = " (${name})**";
            irc = "[${name}]\\u000f";
            minecraft = " (${name})";
          }
          ."${format}";
        channelConfig = builtins.filter (x: x.source != x.target) (
          builtins.concatLists (
            map (
              f:
              lib.mapCartesianProduct
                (
                  { source, target }:
                  {
                    source = source.id;
                    target = target.id;
                    user_prefix = lookupUserPrefix target.format source.name;
                    user_suffix = lookupUserSuffix target.format source.name;
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
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        environment = {
          SEABIRD_HOST = "http://localhost:8080";
          PROXY_CONFIG_FILE = "${configFile}";
        };
        serviceConfig = {
          DynamicUser = true;
          Restart = "always";
          ExecStart = "${pkgs.seabird.seabird-proxy-plugin}/bin/seabird-proxy-plugin";
          EnvironmentFile = [
            config.age.secrets."seabird-proxy-plugin".path
          ];
        };
      };

    age.secrets."seabird-proxy-plugin".file = ../../../secrets + "/seabird-proxy-plugin.age";
  };
}
