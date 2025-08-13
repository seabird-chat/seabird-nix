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
              tag = lib.mkOption {
                default = "0.2.3";
                type = lib.types.str;
              };
              irc = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    nick = lib.mkOption {
                      type = lib.types.str;
                    };
                    user = lib.mkOption {
                      default = config.irc.nick;
                      type = lib.types.str;
                    };
                    name = lib.mkOption {
                      default = config.irc.user;
                      type = lib.types.str;
                    };
                    host = lib.mkOption {
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
                };
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
        "seabird-irc-backend-${name}" = {
          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          environment = {
            SEABIRD_HOST = "http://localhost:8080";
            IRC_NICK = value.irc.nick;
            IRC_USER = value.irc.user;
            IRC_NAME = value.irc.name;
            IRC_HOST = value.irc.host;
            IRC_CHANNELS = lib.strings.concatStringsSep "," value.irc.channels;
            IRC_COMMAND_PREFIX = value.irc.commandPrefix;
          };

          serviceConfig = {
            DynamicUser = true;
            Restart = "always";
            ExecStart = "${pkgs.seabird.seabird-irc-backend}/bin/seabird-irc-backend";
            EnvironmentFile = [
              config.age.secrets."seabird-irc-backend-${name}".path
            ];
          };

        };
      }
    ) cfg;

    age.secrets = lib.attrsets.concatMapAttrs (
      name: value:
      lib.mkIf value.enable {
        "seabird-irc-backend-${name}".file = ../../../secrets + "/seabird-irc-backend-${name}.age";
      }
    ) cfg;
  };
}
