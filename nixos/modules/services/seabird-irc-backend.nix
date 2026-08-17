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
    seabird.services.seabird-irc-backend = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-irc-backend;
      };

      instances = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, config, ... }:
            {
              options = {
                enable = lib.mkEnableOption "seabird-irc-backend";
                package = lib.mkOption {
                  type = lib.types.package;
                  default = cfg.package;
                };
                name = lib.mkOption {
                  default = name;
                  type = lib.types.str;
                };
                secretFile = lib.mkOption {
                  type = lib.types.path;
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
        default = { };
      };
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
          restartTriggers = [ (builtins.hashFile "sha256" value.secretFile) ];

          environment = {
            SEABIRD_HOST = "http://localhost:8080";
            IRC_CHANNELS = lib.strings.concatStringsSep "," value.channels;
            IRC_COMMAND_PREFIX = value.commandPrefix;
          };

          serviceConfig = {
            DynamicUser = true;
            Restart = "always";
            ExecStart = "${value.package}/bin/seabird-irc-backend";
            EnvironmentFile = [
              config.age.secrets."seabird-irc-backend-${value.name}".path
            ];
          };
        };
      }
    ) cfg.instances;

    age.secrets = lib.attrsets.concatMapAttrs (
      name: value:
      lib.mkIf value.enable {
        "seabird-irc-backend-${value.name}".file = value.secretFile;
      }
    ) cfg.instances;
  };
}
