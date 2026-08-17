{
  config,
  lib,
  pkgs,
  ...
}:
{
  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
    '';

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      warn-dirty = false;

      # The guests substitute from the attic cache and are not meant to build,
      # but a cache miss falls back to building locally. Unbounded, that starts
      # one job per core, and eiko's largest process is a qemu guest running
      # production seabird, so an out-of-memory kill lands on prod rather than
      # on the build. Two jobs keeps a miss slow instead of fatal.
      max-jobs = 2;

      # A deploy can outrun the CI build that pushes its closures, and nix
      # remembers "the cache doesn't have this" for an hour by default, so one
      # early query means an hour of building from source after the closure has
      # landed. A minute is short enough to be invisible and still batches the
      # misses of a nixpkgs bump, where the seabird cache is asked first and has
      # none of them.
      narinfo-cache-negative-ttl = 60;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
  };

  # With no swap at all, anonymous pages cannot be evicted anywhere: once page
  # cache is gone the next allocation goes straight to the OOM killer, with no
  # slower-but-alive state in between. zram is compressed swap in RAM, so it
  # costs no disk and gives the kernel somewhere to put cold pages during a
  # spike.
  zramSwap.enable = true;

  users.mutableUsers = false;

  users.users.root.openssh.authorizedKeys.keys = [
    # CI deploy key for the deploy-rs CD pipeline (see .woodpecker.yml). The
    # private half is stored as the `deploy_ssh_key` Woodpecker secret.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBnSwWlN0EldwQphpJ6lxJz4TrZp7F3XasJ72ARVH8VW ci-deploy@seabird.chat"

    # Personal keys
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzuXboQDv2VCig0+A780O0+sKs1euw+3OafnRA6z14P belak@melinoe.elwert.dev"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUSx9TTTHUq4GOkeBU4Ga03QombEBiZLqqa8KIqnnUy kaleb.elwert@work"
  ];

  services.openssh.enable = true;

  environment.enableAllTerminfo = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    jq
    tmux
    vim
    yq
  ];

  time.timeZone = lib.mkDefault "Etc/UTC";
}
