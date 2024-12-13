{ lib, pkgs, ... }:

{
  services.xserver.videoDrivers = lib.mkForce [ "nvidia" ];
  }
