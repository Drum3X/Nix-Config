{ pkgs, ... }: {
  # For courses in Kate: compilers, and the language servers its LSP client
  # starts on its own (clangd for C, jdtls for Java). JDK 25 is the one jdtls
  # runs on; the default jdk (21) would be a second, 420 MB download.
  home.packages = with pkgs; [
    gcc
    jdk25
    clang-tools
    jdt-language-server
  ];
}
