{ pkgs, ... }:

{
  users.users.g.packages = [
    pkgs.steam
  ];
}
