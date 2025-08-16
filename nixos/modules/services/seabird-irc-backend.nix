{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.seabird.services.seabird-irc-backend;
in
{
  options = {
    seabird.services.seabird-irc-backend = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }:
          {
            options = {
              enable = lib.mkEnableOption "seabird-irc-backend";
              name = lib.mkOption {
                default = name;
                type = lib.types.str;
              };
              channels = lib.mkOption {
                type = lib.types.listOf lib.types.str;
              };
              commandPrefix = lib.mkOption {
                type = lib.types.str;
                default = "!";
              };
            };
          }
        )
      );
    };
  };

  config = {
    systemd.services = lib.attrsets.concatMapAttrs (
      name: value:
      lib.mkIf value.enable {
        "seabird-irc-backend-${value.name}" = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          environment = {
            SEABIRD_HOST = "http://localhost:8080";
            IRC_CHANNELS = lib.strings.concatStringsSep "," value.channels;
            IRC_COMMAND_PREFIX = value.commandPrefix;
          };

          serviceConfig = {
            DynamicUser = true;
            Restart = "always";
            ExecStart = "${pkgs.seabird.seabird-irc-backend}/bin/seabird-irc-backend";
            EnvironmentFile = [
              config.age.secrets."seabird-irc-backend-${value.name}".path
            ];
          };
        };
      }
    ) cfg;

    age.secrets = lib.attrsets.concatMapAttrs (
      name: value:
      lib.mkIf value.enable {
        "seabird-irc-backend-${value.name}".file = ../../../secrets + "/seabird-irc-backend-${value.name}.age";
      }
    ) cfg;
  };
}
