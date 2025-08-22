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

      package = lib.mkPackageOption pkgs "haproxy" { };

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

                hosts = lib.mkOption {
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
            name: backend:
            (map (host: "use_backend ${name} if { var(req.fhost) -m str -i ${host} }") backend.hosts)
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

        package = cfg.package;

        config = ''
          global
            log /dev/log local0 debug

          defaults
            log global

            timeout connect 10s
            timeout client 30s
            timeout server 30s
            timeout tunnel 15m

          frontend http
            mode http
            bind :80
            bind :81 proto h2

            option httplog

            http-response add-header X-Backend-Hostname %[hostname]

            #http-request set-var(req.fhost) req.hdr(forwarded),rfc7239_field(host)
            http-request set-var(req.fhost) req.hdr(x-forwarded-host)
            http-request capture var(req.fhost) len 50

            ${builtins.concatStringsSep "\n  " backendMatchers}

          ${builtins.concatStringsSep "\n" backends}
        '';
      };

    networking.firewall.allowedTCPPorts = [
      80
      81
    ];
  };
}
