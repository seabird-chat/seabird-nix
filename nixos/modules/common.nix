{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The same keys that are agenix recipients in secrets.nix are used for root
  # ssh access, so a key that can decrypt a secret can also reach the host.
  keys = import ../../secrets/keys.nix;
in
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
    # private half is stored as the `deploy_ssh_key` Woodpecker secret. It is not
    # an agenix recipient, so it lives here rather than in keys.nix.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBnSwWlN0EldwQphpJ6lxJz4TrZp7F3XasJ72ARVH8VW ci-deploy@seabird.chat"
  ]
  ++ keys.users;

  services.openssh.enable = true;

  environment.enableAllTerminfo = true;

  # sqlite is here because tokens are rows in core's database and there is no CLI
  # to add them, so a host running core needs a client to issue one. The rest is
  # what it takes to answer "why is this service unhappy" over SSH.
  environment.systemPackages = with pkgs; [
    dig
    git
    htop
    iotop
    jq
    lsof
    sqlite
    strace
    sysstat
    tcpdump
    tmux
    vim
    yq
  ];

  time.timeZone = lib.mkDefault "Etc/UTC";
}
