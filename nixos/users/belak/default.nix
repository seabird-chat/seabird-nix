{ pkgs, config, ... }:
{
  users.users.belak = {
    home = "/home/belak";
    isNormalUser = true;
    #hashedPasswordFile = config.age.secrets.belak-password.path;
    description = "Kaleb Elwert";
    extraGroups = [
      "wheel"
      "dialout"
    ];
    shell = pkgs.zsh;
  };

  #age.secrets.belak-password.file = ../../../../secrets/belak-password.age;
}
