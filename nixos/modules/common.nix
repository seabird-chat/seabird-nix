{ lib, pkgs, ... }:
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

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    vim
  ];

  time.timeZone = lib.mkDefault "Etc/UTC";
}
