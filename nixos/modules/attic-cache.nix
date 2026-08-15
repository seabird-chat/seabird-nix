{ config, lib, ... }:
let
  cfg = config.seabird.atticCache;
in
{
  options.seabird.atticCache = {
    enable = lib.mkEnableOption "pulling from the seabird attic binary cache";

    endpoint = lib.mkOption {
      type = lib.types.str;
      default = "https://attic.elwert.cloud";
      description = ''
        Base URL of the attic instance, without a trailing slash.
      '';
    };

    cacheName = lib.mkOption {
      type = lib.types.str;
      default = "seabird";
      description = ''
        Name of the attic cache to pull from.
      '';
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      default = "seabird:9xBUvbtK5/HKJWcGGkDVYIXjMY3r5irQf9bciAOJeHQ=";
      description = ''
        Public key used to verify signatures on paths served by the cache,
        in `<name>:<base64>` form. Not secret. Obtain it with
        `attic cache info ${cfg.cacheName}` against the attic instance.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # The cache is private, so the pull token comes from a machine-wide netrc.
    # It lives here rather than in common.nix because it is the only thing that
    # needs it: a host with no private substituter needs no secret at all, and
    # that is what lets a fresh MicroVM guest boot before it has an agenix key.
    nix.settings = {
      substituters = [ "${cfg.endpoint}/${cfg.cacheName}" ];
      trusted-public-keys = [ cfg.publicKey ];
      netrc-file = config.age.secrets.nix-netrc.path;
    };

    age.secrets.nix-netrc.file = ../../secrets/nix-netrc.age;
  };
}
