{
  description = "Development shell for managing ogadra.net domain delegation with Terraform";

  inputs = {
    hk.url = "github:jdx/hk";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { hk, nixpkgs, ... }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "python3.13-ecdsa-0.19.2"
          ];
        };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          awscli2
          checkov
          gitleaks
          google-cloud-sdk
          hk.packages.${system}.default
          nixfmt
          terraform
          tflint
          trivy
        ];
        shellHook = ''
          hk install
        '';
      };
    };
}
