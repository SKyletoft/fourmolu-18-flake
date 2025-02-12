{
	inputs = {
		# Revision is, as of writing, the latest commit with successfully completed CI
		haskellNix.url = "github:input-output-hk/haskell.nix?rev=38e5c02f9918dbf1c7f606de228daf2ef634a83f";
		nixpkgs.follows = "haskellNix/nixpkgs-unstable";
		flake-utils.url = "github:numtide/flake-utils";
	};
	outputs = { self, nixpkgs, flake-utils, haskellNix }:
	flake-utils.lib.eachDefaultSystem (system:
	let
		overlays = [ haskellNix.overlay
			(final: prev: {
				fourmolu_18 =
					final.haskell-nix.project' {
						src = pkgs.fetchFromGitHub {
							owner = "fourmolu";
							repo = "fourmolu";
							rev = "v0.18.0.0";
							sha256 = "sha256-VygaYu/sK61TFaKXnsfC+GaXqRccb1Ue/4Ut5vbdpvA=";
						};
						compiler-nix-name = "ghc9121";
						shell = {
							tools = {
								cabal = {};
								hlint = {};
								haskell-language-server = {};
							};
							buildInputs = with pkgs; [
								nixpkgs-fmt
							];
						};
					};
			})
		];
		pkgs = import nixpkgs {
			inherit system overlays;
			inherit (haskellNix) config;
		};
		flake = pkgs.fourmolu_18.flake {};
	in { packages = rec {
		default = fourmolu;
		fourmolu =  flake.packages."fourmolu:exe:fourmolu";
		fourmolu18 = pkgs.writeShellScriptBin "fourmolu18" "${fourmolu}/bin/fourmolu $@";
	}; });
}
