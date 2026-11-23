{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.services.seabird-rcon-plugin;

  unitName = "seabird-rcon-plugin";

  settingsFormat = pkgs.formats.toml { };

  # Passwords arrive through LoadCredential, so the generated config only
  # holds their paths.
  configFile = settingsFormat.generate "seabird-rcon-plugin.toml" {
    servers = lib.mapAttrs (
      name: server:
      {
        inherit (server)
          address
          channels
          operators
          admins
          ;
        password_file = "/run/credentials/${unitName}.service/${name}";
        operator_channels = server.operatorChannels;
      }
      // lib.optionalAttrs (server.mapUrl != null) { map_url = server.mapUrl; }
    ) cfg.servers;
  };

  passwordSecret = name: "seabird-rcon-plugin-${name}";
in
{
  options = {
    seabird.services.seabird-rcon-plugin = {
      enable = lib.mkEnableOption "seabird-rcon-plugin";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.seabird.seabird-rcon-plugin;
      };

      # Must provide SEABIRD_TOKEN.
      secretFile = lib.mkOption {
        type = lib.types.path;
      };

      servers = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              # RCON host:port.
              address = lib.mkOption {
                type = lib.types.str;
              };
              # agenix file holding just the RCON password.
              passwordSecretFile = lib.mkOption {
                type = lib.types.path;
              };
              mapUrl = lib.mkOption {
                type = lib.types.nullOr lib.types.str;
                default = null;
              };
              # Channels where commands default to this server.
              channels = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              # Anyone talking in these channels is an operator.
              operatorChannels = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              # Seabird user IDs. Admins can also run raw console commands.
              operators = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
              admins = lib.mkOption {
                type = lib.types.listOf lib.types.str;
                default = [ ];
              };
            };
          }
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.${unitName} = {
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
      restartTriggers = [
        (builtins.hashFile "sha256" cfg.secretFile)
      ]
      ++ lib.mapAttrsToList (_: server: builtins.hashFile "sha256" server.passwordSecretFile) cfg.servers;
      environment = {
        SEABIRD_HOST = "http://localhost:8080";
        RCON_CONFIG = configFile;
      };
      serviceConfig = {
        DynamicUser = true;
        Restart = "always";
        RestartSec = 5;
        ExecStart = "${cfg.package}/bin/seabird-rcon-plugin";
        EnvironmentFile = [
          config.age.secrets."seabird-rcon-plugin".path
        ];
        LoadCredential = lib.mapAttrsToList (
          name: _: "${name}:${config.age.secrets.${passwordSecret name}.path}"
        ) cfg.servers;
      };
    };

    age.secrets = {
      "seabird-rcon-plugin".file = cfg.secretFile;
    }
    // lib.mapAttrs' (
      name: server: lib.nameValuePair (passwordSecret name) { file = server.passwordSecretFile; }
    ) cfg.servers;
  };
}
