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
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
  };

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
