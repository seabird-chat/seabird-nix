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

  # Podman stores a number of files in /tmp and has issues when machines reboot,
  # so it's easiest to make sure they get cleared.
  boot.tmp.cleanOnBoot = true;

  services.openssh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    htop
    vim
  ];

  time.timeZone = lib.mkDefault "Etc/UTC";
}
