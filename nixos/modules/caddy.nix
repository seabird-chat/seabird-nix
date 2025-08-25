{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.seabird.caddy;
in
{
  options = {
    seabird.caddy = {
      enable = lib.mkEnableOption "caddy";
      package = lib.mkPackageOption pkgs "caddy" { };

      virtualHosts = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule {
            options = {
              hosts = lib.mkOption {
                type = lib.types.listOf lib.types.str;
              };

              backend = lib.mkOption {
                type = lib.types.str;
              };

              extraConfig = lib.mkOption {
                type = lib.types.lines;
                default = "";
              };
            };
          }
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = cfg.package;

      globalConfig = ''
        auto_https off
        servers {
          trusted_proxies static private_ranges
        }
      '';

      virtualHosts = builtins.mapAttrs (
        name: value:
        let
          host = builtins.head value.hosts;
          extraHosts = builtins.tail value.hosts;
        in
        {
          hostName = "http://${host}";
          serverAliases = map (alias: "http://${alias}") extraHosts;
          extraConfig = ''
            reverse_proxy ${value.backend}
            ${value.extraConfig}
          '';
        }
      ) cfg.virtualHosts;
    };

    networking.firewall.allowedTCPPorts = [
      80
    ];
  };
}
