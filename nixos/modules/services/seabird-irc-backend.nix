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
