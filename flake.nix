{
  description = "Xavier's NixOS Configuration";

  nixConfig = {
    experimental-features = [ "nix-command" "flakes" ];
    extra-substituters = [
      "https://hyprland.cachix.org"
      "https://nix-community.cachix.org"
      "https://nix-gaming.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-modules = {
      url = "github:xavierlauzon/nixos-modules";
      #url = "path:/home/xavier/src/nixos-modules";
    };
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      inherit (self) outputs;
      lib = nixpkgs.lib;
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forEachSystem = f: lib.genAttrs systems (sys: f pkgsFor.${sys});
      pkgsFor = lib.genAttrs systems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
          overlays = [
            outputs.overlays.additions
            outputs.overlays.modifications
            outputs.overlays.unstable-packages
          ];
      });
    in
    {
      inherit lib;
      overlays = import ./overlays {inherit inputs;};
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

      nixosConfigurations = {
        ms1 = lib.nixosSystem { # Server Added 2024-12-07
          modules = [ ./hosts/ms1 ];
          specialArgs = { inherit self inputs outputs; };
        };
        ms2 = lib.nixosSystem { # Server Added 2024-12-07
          modules = [ ./hosts/ms2 ];
          specialArgs = { inherit self inputs outputs; };
        };
        blackhawk = lib.nixosSystem { # Server Added 2024-08-23
          modules = [ ./hosts/blackhawk ];
          specialArgs = { inherit self inputs outputs; };
        };
        xavierdesktop = lib.nixosSystem { # Desktop Added 2024-08-07
          modules = [ ./hosts/xavierdesktop ];
          specialArgs = { inherit self inputs outputs; };
        };
        rescue = lib.nixosSystem { # Rescue Added 2024-11-29
          modules = [ ./hosts/rescue ];
          specialArgs = { inherit self inputs outputs; };
        };
      };
  };
}
