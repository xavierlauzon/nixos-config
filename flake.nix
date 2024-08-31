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
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
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
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, nixpkgs-darwin, ... }@inputs:
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
      nixosModules = import ./modules;
      overlays = import ./overlays {inherit inputs;};
      packages = forEachSystem (pkgs: import ./pkgs { inherit pkgs; });
      formatter = forEachSystem (pkgs: pkgs.nixpkgs-fmt);

#      darwinConfigurations = {
#        xaviermacbook = darwin.lib.darwinSystem {
#          modules = [ ./hosts/xaviermacbook ];
#          specialArgs = { inherit inputs outputs; };
#        };
#      };

      nixosConfigurations = {
        blackhawk = lib.nixosSystem { # Server Added 2024-08-23 
          modules = [ ./hosts/blackhawk ];
          specialArgs = { inherit inputs outputs; };
        };

        xavierdesktop = lib.nixosSystem { # Desktop Added 2024-08-07 
          modules = [ ./hosts/xavierdesktop ];
          specialArgs = { inherit inputs outputs; };
        };
    };
  };
}
