{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.seabird.services.seabird-archipelago-backend;

  enabledInstances = lib.filterAttrs (_: value: value.enable) cfg.instances;
in
{
  options = {
    seabird.services.seabird-archipelago-backend = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-archipelago-backend;
      };

      # One process per Archipelago room, keyed by instance name.
      instances = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, config, ... }:
            {
              options = {
                enable = lib.mkEnableOption "seabird-archipelago-backend";
                package = lib.mkOption {
                  type = lib.types.package;
                  default = cfg.package;
                };
                name = lib.mkOption {
                  default = name;
                  type = lib.types.str;
                };
                # Backend ID as seen by seabird-core. Defaults to the instance
                # name so every room is unique; the proxy plugin addresses the
                # room as archipelago://<id>/<channel>.
                id = lib.mkOption {
                  type = lib.types.str;
                  default = config.name;
                };
                # Must provide SEABIRD_TOKEN and the room address as either
                # ARCHIPELAGO_ROOM (archipelago.gg room ID or URL) or
                # ARCHIPELAGO_URL (static server address), plus
                # ARCHIPELAGO_PASSWORD if the room has one. The room address is
                # kept out of the config since it grants access to the game.
                secretFile = lib.mkOption {
                  type = lib.types.path;
                };
                slot = lib.mkOption {
                  type = lib.types.str;
                };
                channel = lib.mkOption {
                  type = lib.types.str;
                  default = "room";
                };
                # "!" is reserved for Archipelago server commands.
                commandPrefix = lib.mkOption {
                  type = lib.types.str;
                  default = ".";
                };
                itemFilter = lib.mkOption {
                  type = lib.types.listOf (
                    lib.types.enum [
                      "progression"
                      "useful"
                      "filler"
                      "trap"
                    ]
                  );
                  default = [
                    "progression"
                    "useful"
                    "filler"
                    "trap"
                  ];
                };
                deathlink = lib.mkOption {
                  type = lib.types.bool;
                  default = true;
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
    systemd.services = lib.attrsets.concatMapAttrs (name: value: {
      "seabird-archipelago-backend-${value.name}" = {
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
        restartTriggers = [ (builtins.hashFile "sha256" value.secretFile) ];

        environment = {
          SEABIRD_HOST = "http://localhost:8080";
          SEABIRD_ID = value.id;
          ARCHIPELAGO_SLOT = value.slot;
          ARCHIPELAGO_CHANNEL = value.channel;
          ARCHIPELAGO_COMMAND_PREFIX = value.commandPrefix;
          ARCHIPELAGO_ITEM_FILTER = lib.strings.concatStringsSep "," value.itemFilter;
          ARCHIPELAGO_DEATHLINK = lib.boolToString value.deathlink;
        };

        serviceConfig = {
          DynamicUser = true;
          Restart = "always";
          RestartSec = 5;
          ExecStart = "${value.package}/bin/seabird-archipelago-backend";
          EnvironmentFile = [
            config.age.secrets."seabird-archipelago-backend-${value.name}".path
          ];
        };
      };
    }) enabledInstances;

    age.secrets = lib.attrsets.concatMapAttrs (name: value: {
      "seabird-archipelago-backend-${value.name}".file = value.secretFile;
    }) enabledInstances;
  };
}
