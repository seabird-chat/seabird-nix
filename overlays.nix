inputs@{
  self,
  nixpkgs-unstable,
  agenix,
  deploy-rs,
  ...
}:
{
  seabird =
    final: _prev:
    let
      system = final.stdenv.hostPlatform.system;
      seabirdPackages = final.lib.packagesFromDirectoryRecursive {
        inherit (final) callPackage;
        directory = ./pkgs;
      };
    in
    {
      seabird = seabirdPackages // {
        # Core
        seabird-core = inputs.seabird-core-release.packages.${system}.default;

        # Backends
        seabird-discord-backend = inputs.seabird-discord-backend-release.packages.${system}.default;
        seabird-irc-backend = inputs.seabird-irc-backend-release.packages.${system}.default;

        # Plugins
        seabird-adventofcode-plugin = inputs.seabird-adventofcode-plugin-release.packages.${system}.default;
        seabird-datadog-plugin = inputs.seabird-datadog-plugin-release.packages.${system}.default;
        seabird-github-plugin = inputs.seabird-github-plugin-release.packages.${system}.default;
        seabird-nwwsio-plugin = inputs.seabird-nwwsio-plugin-release.packages.${system}.default;
        seabird-plugin-bundle = inputs.seabird-plugin-bundle-release.packages.${system}.default;
        seabird-proxy-plugin = inputs.seabird-proxy-plugin-release.packages.${system}.default;
        seabird-stock-plugin = inputs.seabird-stock-plugin-release.packages.${system}.default;
        seabird-url-plugin = inputs.seabird-url-plugin-release.packages.${system}.default;

        # Other
        seabird-webhook-receiver = inputs.seabird-webhook-receiver-release.packages.${system}.default;
      };
      seabird-staging = {
        # Core
        seabird-core = inputs.seabird-core-dev.packages.${system}.default;

        # Backends
        seabird-discord-backend = inputs.seabird-discord-backend-dev.packages.${system}.default;
        seabird-irc-backend = inputs.seabird-irc-backend-dev.packages.${system}.default;

        # Plugins
        seabird-adventofcode-plugin = inputs.seabird-adventofcode-plugin-dev.packages.${system}.default;
        seabird-datadog-plugin = inputs.seabird-datadog-plugin-dev.packages.${system}.default;
        seabird-github-plugin = inputs.seabird-github-plugin-dev.packages.${system}.default;
        seabird-nwwsio-plugin = inputs.seabird-nwwsio-plugin-dev.packages.${system}.default;
        seabird-plugin-bundle = inputs.seabird-plugin-bundle-dev.packages.${system}.default;
        seabird-proxy-plugin = inputs.seabird-proxy-plugin-dev.packages.${system}.default;
        seabird-stock-plugin = inputs.seabird-stock-plugin-dev.packages.${system}.default;
        seabird-url-plugin = inputs.seabird-url-plugin-dev.packages.${system}.default;

        # Other
        seabird-webhook-receiver = inputs.seabird-webhook-receiver-dev.packages.${system}.default;
      };
    };

  go = _final: prev: {
    seabirdBuildGoModule = prev.buildGoModule.override { go = prev.go_1_26; };
  };

  agenix = agenix.overlays.default;

  deploy-rs = deploy-rs.overlays.default;

  unstable = final: _prev: {
    unstable = import nixpkgs-unstable {
      inherit (final) config;
      inherit (final.stdenv.hostPlatform) system;
    };
  };

  # This is a modified version of what's in the deploy-rs readme. For some
  # reason overriding deploy-rs entirely seems to clobber the needed `lib` attr,
  # and oddly enough the `deploy-rs` binary is accessed through
  # deploy-rs.reploy-rs, so we need to provide that as well.
  #
  # Note that this depends on our "unstable" overlay because it's the easiest
  # way to make sure we get a package from nixpkgs and not from the deploy-rs
  # source. Another option would be creating a new nixpkgs instance.
  deploy-rs-pkg-override = final: prev: {
    deploy-rs = final.unstable.deploy-rs // {
      inherit (final.unstable) deploy-rs;
      inherit (prev.deploy-rs) lib;
    };
  };
}
