let
  user-belak-work = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFUSx9TTTHUq4GOkeBU4Ga03QombEBiZLqqa8KIqnnUy";
  user-belak-melinoe = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMzuXboQDv2VCig0+A780O0+sKs1euw+3OafnRA6z14P";
  user-belak-zagreus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGNHMEfjGg5ek6OtbFytZ/zCSZosT8aHqHRfnufb3gIi";

  users = [
    user-belak-work
    user-belak-melinoe
    user-belak-zagreus
  ];

  system-vivi = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDx5Y7VvA9CUdrsiVpNbRufBdJdvJZEfRQXIGnPgqynH";

  systems = [
    system-vivi
  ];
in
{
  "secrets/belak-password.age".publicKeys = users ++ systems;
  "secrets/seabird-irc-backend-whyte.age".publicKeys = users ++ systems;
}
