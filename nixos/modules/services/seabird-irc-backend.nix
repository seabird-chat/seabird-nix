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
            enable = lib.mkEnableOption "seabird-irc-backend";
            name = lib.mkOption {
              default = name;
              type = lib.types.str;
            };
            tag = lib.mkOption {
              default = "0.2.1";
              type = lib.types.str;
            };
            ircNick = lib.mkOption {
              type = lib.types.str;
            };
            ircUser = lib.mkOption {
              default = cfg.ircNick;
              type = lib.types.str;
            };
            ircName = lib.mkOption {
              default = cfg.ircUser;
              type = lib.types.str;
            };
            ircHost = lib.mkOption {
              type = lib.types.str;
            };
            ircChannels = lib.mkOption {
              type = lib.types.listOf lib.types.str;
            };
            ircCommandPrefix = lib.mkOption {
              type = lib.types.str;
              default = "!";
            };
          }
        )
      );
    };
  };

  config = lib.attrsets.concatMapAttrs (
    name: backendCfg:
    lib.mkIf backendCfg.enable {
      virtualisation.oci-containers.containers."seabird-irc-backend-${name}" = {
        image = "ghcr.io/seabird-chat/seabird-irc-backend:${cfg.tag}";
        environment = {
          SEABIRD_HOST = "http://seabird-core-{{ seabird_env }}:11235";
          IRC_NICK = backendCfg.ircNick;
          IRC_USER = backendCfg.ircUser;
          IRC_NAME = backendCfg.ircName;
          IRC_HOST = backendCfg.ircHost;
          IRC_CHANNELS = lib.strings.concatStringsSep "," backendCfg.ircChannels;
          IRC_COMMAND_PREFIX = backendCfg.ircCommandPrefix;
        };

        environmentFiles = [
          config.age.secrets."seabird-irc-backend-${name}".path
        ];
      };

      age.secrets."seabird-irc-backend-${name}".file = ../../../secrets
      + "/seabird-irc-backend-${name}.age";
    }
  ) cfg;
}
