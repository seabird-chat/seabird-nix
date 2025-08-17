{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.seabird.haproxy;
in
{
  options = {
    seabird.haproxy = {
      enable = lib.mkEnableOption "haproxy";

      backends = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { name, ... }:
            {
              options = {
                name = lib.mkOption {
                  type = lib.types.str;
                  default = name;
                };

                servers = lib.mkOption {
                  type = with lib.types; attrsOf str;
                };

                matchers = lib.mkOption {
                  type = with lib.types; listOf str;
                };
              };
            }
          )
        );
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.haproxy =
      let
        backendMatchers = lib.flatten (
          lib.mapAttrsToList (
            name: backend: (map (matcher: "use_backend ${name} ${matcher}") backend.matchers)
          ) cfg.backends
        );

        backends = lib.mapAttrsToList (
          name: backend:
          let
            servers = builtins.concatStringsSep "\n  " (
              lib.mapAttrsToList (serverName: server: "server ${serverName} ${server}") backend.servers
            );
          in
          ''
            backend ${backend.name}
              mode http
              ${servers}
          ''
        ) cfg.backends;
      in
      {
        enable = true;

        config = ''
          global
            log /dev/log local0 info

          defaults
            log global

            timeout connect 10s
            timeout client 30s
            timeout server 30s
            timeout tunnel 15m

          frontend http
            mode http
            bind :80

            option httplog

            ${builtins.concatStringsSep "\n  " backendMatchers}

          ${builtins.concatStringsSep "\n" backends}
        '';
      };

    networking.firewall.allowedTCPPorts = [ 80 ];
  };
}
