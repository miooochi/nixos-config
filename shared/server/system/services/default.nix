{ sharedLib, ... }:

{
  imports = sharedLib.scanPaths ./.;
}