{ pkgs ? import <nixpkgs> {} }:
let
  libs = with pkgs; [
    llvm
    libllvm
    cargo
    rustc
    lld
    pkg-config
    gdb
  ];
  lib = libs;
in
pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    codespell
    doxygen
  ];
  buildInputs = libs;
  # XDG_DATA_DIRS = builtins.getEnv "XDG_DATA_DIRS";
  # XDG_RUNTIME_DIRS = "/run/user/1001/";
  shellHook = ''
    echo "Xarxo Dev Shell"
  '';
}
