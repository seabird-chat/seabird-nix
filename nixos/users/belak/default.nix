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
  };

  #age.secrets.belak-password.file = ../../../../secrets/belak-password.age;
}
