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
      default = "seabird:FGiZCzPjPpnQHwe3RuxA88OpfhjWEHYC6CQwRlgRbag=";
      description = ''
        Public key used to verify signatures on paths served by the cache,
        in `<name>:<base64>` form. Not secret. Obtain it with
        `attic cache info ${cfg.cacheName}` against the attic instance.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # The cache is private; the pull token lives in the machine-wide netrc
    # (nix.settings.netrc-file in common.nix).
    nix.settings = {
      substituters = [ "${cfg.endpoint}/${cfg.cacheName}" ];
      trusted-public-keys = [ cfg.publicKey ];
    };
  };
}
