{ pkgs, config, ... }:
{
  users.users.belak = {
    home = "/home/belak";
    isNormalUser = true;
    hashedPasswordFile = config.age.secrets.belak-password.path;
    extraGroups = [
      "wheel"
      "dialout"
    ];
  };

  age.secrets.belak-password.file = ../../../secrets/common/belak-password.age;
}
