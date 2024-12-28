{ inputs, lib, outputs, pkgs, ... }:
  with lib;
{
  environment = {
    systemPackages = with pkgs; [
      git
      nvd
    ];
  };

  nix = {
    gc = {
      automatic = mkDefault true;
      dates = mkDefault "19:00";
      persistent = mkDefault true;
      options = mkDefault "--delete-older-than 10d";
    };

    settings = {
      accept-flake-config = true;
      auto-optimise-store = mkDefault true;
      experimental-features = [ "nix-command" "flakes" ];
      # show more log lines for failed builds
      log-lines = 30;
      # Free up to 10GiB whenever there is less than 5GB left.
      # this setting is in bytes, so we multiply with 1024 thrice
      min-free = mkDefault "${toString (5 * 1024 * 1024 * 1024)}";
      max-free = mkDefault "${toString (10 * 1024 * 1024 * 1024)}";
      max-jobs = mkDefault "auto";
      trusted-users = [ "root" "@wheel" ];
      warn-dirty = false;
    };

    package = pkgs.nixVersions.stable;
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
  };

  nixpkgs = {
    overlays = builtins.attrValues outputs.overlays;
    config = {
      allowBroken = mkDefault false;
      allowUnfree = mkDefault true;
      allowUnsupportedSystem = mkDefault true;
      permittedInsecurePackages = [
      ];
    };
  };

  programs = {
    bash = {
      shellInit = ''
        alias nix_package_size="nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort"
      '';
    };
  };

  system = {
    autoUpgrade.enable = mkDefault false;
    stateVersion = mkDefault "23.11";
  };
}

