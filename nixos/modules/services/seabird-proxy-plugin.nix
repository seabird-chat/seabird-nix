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
        type = lib.types.listOf (lib.types.listOf lib.types.str);
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.seabird-proxy-plugin =
      let
        formatForId = (
          id:
          if lib.strings.hasPrefix "discord://" id then
            "Discord"
          else if lib.strings.hasPrefix "irc://" id then
            "IRC"
          else if lib.strings.hasPrefix "minecraft://" id then
            "Minecraft"
          else
            abort "id prefix is invalid"
        );
        lookupUserPrefix =
          format: name:
          let
            ircBold = builtins.fromJSON ''"\u0002" '';
          in
          {
            Discord = "**";
            IRC = "${ircBold}";
            Minecraft = "";
          }
          ."${format}";
        lookupUserSuffix =
          format: name:
          let
            ircReset = builtins.fromJSON ''"\u000f" '';
          in
          {
            Discord = " (${name})**";
            IRC = "[${name}]${ircReset}";
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
                    targetFormat = formatForId target;
                    sourceFormat = formatForId source;
                  in
                  {
                    source = source;
                    target = target;
                    user_prefix = lookupUserPrefix targetFormat sourceFormat;
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
