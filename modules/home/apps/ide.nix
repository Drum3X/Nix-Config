{pkgs, ...}: {
  # For courses in Kate: compilers, and the language servers its LSP client
  # starts on its own (clangd for C, jdtls for Java).
  home.packages = with pkgs; [
    gcc
    jdk
    clang-tools
    jdt-language-server
  ];
}
