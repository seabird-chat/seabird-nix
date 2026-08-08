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

      # Machine-wide credentials for private substituters (e.g. the seabird
      # attic cache).
      netrc-file = config.age.secrets.nix-netrc.path;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 2d";
    };
  };

  age.secrets.nix-netrc.file = ../../secrets/nix-netrc.age;

  users.mutableUsers = false;

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
