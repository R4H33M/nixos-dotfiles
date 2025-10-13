{ pkgs, ... }:
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "asus-gu605c-acpi";
  version = "0.0.1";

  src = ./gu605c-spi-cs-gpio.asl;

  nativeBuildInputs = [
    pkgs.acpica-tools
    pkgs.cpio
  ];

  phases = [
    "buildPhase"
    "installPhase"
  ];

  buildPhase = ''
    mkdir -p kernel/firmware/acpi
    iasl -we -p kernel/firmware/acpi/${finalAttrs.pname} ${finalAttrs.src}
    find kernel | cpio -H newc -o > ${finalAttrs.pname}.cpio
  '';

  installPhase = ''
    mkdir -p $out
    cp ${finalAttrs.pname}.cpio $out/
  '';
})
