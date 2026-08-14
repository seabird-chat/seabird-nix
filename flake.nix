{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # NOTE: we don't explicitly depend on home-manager, but there's a narHash
    # mismatch when we let agenix define it, so we include it here so we can
    # bump and control the version.
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Seabird core
    seabird-core-release = {
      url = "github:seabird-chat/seabird-core/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-core-dev = {
      url = "github:seabird-chat/seabird-core";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Seabird backends
    seabird-discord-backend-release = {
      url = "github:seabird-chat/seabird-discord-backend/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-discord-backend-dev = {
      url = "github:seabird-chat/seabird-discord-backend";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-irc-backend-release = {
      url = "github:seabird-chat/seabird-irc-backend/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-irc-backend-dev = {
      url = "github:seabird-chat/seabird-irc-backend";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Seabird plugins
    seabird-datadog-plugin-release = {
      url = "github:seabird-chat/seabird-datadog-plugin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-datadog-plugin-dev = {
      url = "github:seabird-chat/seabird-datadog-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-adventofcode-plugin-release = {
      url = "github:seabird-chat/seabird-adventofcode-plugin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-adventofcode-plugin-dev = {
      url = "github:seabird-chat/seabird-adventofcode-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-github-plugin-release = {
      url = "github:seabird-chat/seabird-github-plugin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-github-plugin-dev = {
      url = "github:seabird-chat/seabird-github-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-plugin-bundle-release = {
      url = "github:seabird-chat/seabird-plugin-bundle/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-plugin-bundle-dev = {
      url = "github:seabird-chat/seabird-plugin-bundle";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-proxy-plugin-release = {
      url = "github:seabird-chat/seabird-proxy-plugin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-proxy-plugin-dev = {
      url = "github:seabird-chat/seabird-proxy-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-nwwsio-plugin-release = {
      url = "github:seabird-chat/seabird-nwwsio-plugin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-nwwsio-plugin-dev = {
      url = "github:seabird-chat/seabird-nwwsio-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-stock-plugin-release = {
      url = "github:seabird-chat/seabird-stock-plugin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-stock-plugin-dev = {
      url = "github:seabird-chat/seabird-stock-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-url-plugin-release = {
      url = "github:seabird-chat/seabird-url-plugin/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-url-plugin-dev = {
      url = "github:seabird-chat/seabird-url-plugin";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Other
    seabird-webhook-receiver-release = {
      url = "github:seabird-chat/seabird-webhook-receiver/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    seabird-webhook-receiver-dev = {
      url = "github:seabird-chat/seabird-webhook-receiver";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      ...
    }:
    let
      myLib = import ./lib.nix inputs;
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];

      flake = {
        overlays = import ./overlays.nix inputs;

        nixosModules.default = import ./nixos/modules;

        nixosConfigurations = {
          "eiko" = myLib.mkNixosSystem {
            modules = [
              ./nixos/hosts/eiko
              ./nixos/users/belak
            ];
          };

          "vivi" = myLib.mkNixosSystem {
            modules = [
              ./nixos/hosts/vivi
              ./nixos/users/belak
              ./nixos/users/ghavil
            ];
          };
        };

        deploy.nodes = {
          # eiko sits on the homelab network rather than behind the seabird
          # edge, so it is reached by its internal name.
          "eiko" = {
            hostname = "eiko.infra.seabird.chat";
            profiles.system = myLib.mkNixosDeploy self.nixosConfigurations."eiko";
          };

          "vivi" = {
            hostname = "vivi.infra.seabird.chat";
            profiles.system = myLib.mkNixosDeploy self.nixosConfigurations."vivi";
          };
        };
      };

      perSystem =
        {
          pkgs,
          system,
          lib,
          ...
        }:
        {
          _module.args.pkgs = import nixpkgs {
            inherit system;
            overlays = builtins.attrValues self.overlays;
            config = { };
          };

          formatter = pkgs.treefmt.withConfig {
            runtimeInputs = [ pkgs.nixfmt ];

            settings = {
              # Log level for files treefmt won't format
              on-unmatched = "info";

              # Configure nixfmt for .nix files
              formatter.nixfmt = {
                command = "nixfmt";
                includes = [ "*.nix" ];
              };
            };
          };

          packages = pkgs.seabird // {
            # Aggregate target so CI can build every seabird package (and
            # push their closures to the attic cache) in one derivation.
            all = pkgs.linkFarmFromDrvs "seabird-all" (
              (lib.attrValues pkgs.seabird) ++ (lib.attrValues pkgs.seabird-staging)
            );
          };

          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.agenix
              pkgs.deploy-rs
            ];
          };

          # Pinned toolchain for the attic push pipeline (see .woodpecker.yml).
          devShells.ci = pkgs.mkShell {
            packages = [
              pkgs.attic-client
            ];
          };

          # Toolchain for the deploy-rs CD pipeline (see .woodpecker.yml).
          # openssh provides ssh-agent/ssh-add for the deploy key.
          devShells.deploy = pkgs.mkShell {
            packages = [
              pkgs.deploy-rs
              pkgs.openssh
            ];
          };
        };
    };
}
