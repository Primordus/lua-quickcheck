{ luaVersion ? "luajit", pkgs ? import ./nix/packages.nix {} }:

with pkgs;
with pkgs."${luaVersion}Packages";

let
  buildArgs = { inherit buildLuarocksPackage fetchurl lua; };
  deps = builtins.mapAttrs (dep: path: import path buildArgs) {
    moonscript = ./nix/moonscript.nix;
    luacov = ./nix/luacov.nix;
    luacov-coveralls = ./nix/luacov-coveralls.nix;
    lanes = ./nix/lanes.nix;
    ldoc = ./nix/ldoc.nix;
  };
  ffi = if isLuaJIT then [] else [ luaffi ];
  runTimeDeps = [ lua argparse luafilesystem ];
  testDeps = with deps; ffi ++ [
    lanes
    moonscript
    busted
    luacheck
    luacov
    luacov-coveralls
    ldoc
  ];
in
  {
    lua-quickcheck = stdenv.mkDerivation rec {
      name = "lua-quickcheck";
      env = buildEnv { name = name; paths = buildInputs; };
      buildInputs = runTimeDeps;
      src = ./.;
    };
    shell = mkShell {
      inputsFrom = testDeps;
      buildInputs = runTimeDeps ++ testDeps;
    };
  }
