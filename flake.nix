{
  description = "llvm module devkit";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let 
        pkgs = nixpkgs.legacyPackages.${system}; 
      in with pkgs; {
        # checks.default = stdenv.mkDerivation {
        #   pname = "llvm-module-devkit";
        #   version = "0.1.0";

        #   src = ./.;

        #   nativeBuildInputs = [
        #     llvmPackages_20.libllvm
        #   ];

        #   buildInputs = [
        #     # xmake
        #   ];

        #   buildPhase = "${llvmPackages_20.libllvm.} -c src/main.cpp -v";
        # };

        packages.default = stdenv.mkDerivation
        {
          pname = "llvm-module-devkit";
          version = "0.1.0";

          src = ./.;

          nativeBuildInputs = [
            llvmPackages_20.libllvm
          ];

          buildInputs = [
            xmake
            doxygen
            llvmPackages_20.clang-unwrapped
          ];

          buildPhase = "xmake";

          installPhase = ''
            mkdir -p $out/bin
            cp -r build/* $out/bin
          '';
        };

        # Use magic incantation to enable native compilation with clang & lld
        devShells.default = mkShell rec
        # .override { 
        #   stdenv = llvmPackages_20.libcxxStdenv; 
        # } 
        {
          name = "llvm-env";

          buildInputs = [
            xmake
            llvmPackages_20.clang-tools
            llvmPackages_20.lldb
            llvmPackages_20.libllvm
            llvmPackages_20.libcxx
            llvmPackages_20.clang
            doxygen
          ];

          CPATH = lib.makeSearchPathOutput "dev" "include" buildInputs;
        };
      }
    );
}
