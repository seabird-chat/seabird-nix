{ pkgs, config, ... }:
{
  users.users.ghavil = {
    home = "/home/ghavil";
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.ghavil-password.path;
    extraGroups = [
      "wheel"
      "dialout"
    ];
  };

  age.secrets.ghavil-password.file = ../../../secrets/ghavil-password.age;
}
