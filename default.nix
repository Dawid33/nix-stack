{ pkgs ? import <nixpkgs> {} }:

let 
    x = "hello";
in {
    nginx = import ./nginx pkgs;
}