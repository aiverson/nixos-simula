{ config ? {}, lib? {}, pkgs ? import <nixpkgs> {}, ... }:

let
  godot-src = pkgs.fetchFromGitHub {
    owner = "SimulaVR";
    repo = "godot";
    rev = "d3f7cb9633d0cb203e8d64cc12a7a3f8cd7310e6";
    sha256 = "0vpm5xsb26bzshyxqa3y05kdfvzrdg9n9sm69ihsm3xhn0bgfvli";
  };
  gdwlroots-src = pkgs.fetchFromGitHub {
    owner = "SimulaVR";
    repo = "gdwlroots";
    rev = "10540d18b07b0308f34ec3a5cb5b98c327a6ce7d";
    sha256 = "19kwswqfswwmvqqg2df3yfqgayqs77f8kaf99riwi1pmi5nnkvi6";
  };
  godot = pkgs.stdenv.mkDerivation rec {
    src = godot-src;
    name = "simula-godot";
    platform = "server";
    buildInputs = [
      pkgs.scons
      pkgs.pkgconfig

      pkgs.x11
      pkgs.xorg.libXcursor
      pkgs.libxkbcommon
      pkgs.xorg.libXinerama
      pkgs.xorg.libXrandr
      pkgs.xorg.libXi
      
      pkgs.wlroots
      pkgs.xwayland
      pkgs.wayland-protocols

      pkgs.libglvnd.dev
      pkgs.libGL
      #pkgs.mesa.dev
      #pkgs.libGLU
    ];
    patches = [
      ./dont_clobber_environment.patch
      ./pkg_config_additions.patch
    ];
    configurePhase = ''
      cp -r ${gdwlroots-src} modules/gdwlroots
      chmod u+w -R modules/gdwlroots
    '';
    buildPhase = ''
      scons platform=${platform} -j $NIX_BUILD_CORES
    '';
  };
in
godot
