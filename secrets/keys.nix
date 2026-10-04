# Public SSH keys, used as both agenix recipients and root's authorizedKeys, so
# a key that can decrypt a secret can also log in to the host holding it.
rec {
  user-belak-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUSx9TTTHUq4GOkeBU4Ga03QombEBiZLqqa8KIqnnUy";
  user-belak-melinoe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzuXboQDv2VCig0+A780O0+sKs1euw+3OafnRA6z14P";
  user-belak-zagreus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNHMEfjGg5ek6OtbFytZ/zCSZosT8aHqHRfnufb3gIi";

  users = [
    user-belak-work
    user-belak-melinoe
    user-belak-zagreus
  ];

  system-atla = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGWRXYt2cEr59j/GbKn9jDydqlVdSg62bLf28xiHYKrp";
  system-eiko = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGFpH5p7ODkUq0kLqda1/fghcCo+MxvCZLdKOfhZCtK+";
  system-kupo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE679sZWB/+sWPM/W29xxB/NKopAkE13daMDXlRsecEE";
  system-stiltzkin = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPY4Di/gKC190MFcJrPtMGgXhP1CeKtLrIQuBopvquG";
  system-monty = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAoM1CNyWuMFMkG2QC4/1ef4nJXAG+zVdl5CsmbO1NAZ";

  systems = [
    system-atla
    system-eiko
    system-kupo
    system-stiltzkin
    system-monty
  ];
}
