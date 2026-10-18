{pkgs, ...}: let
  # git signs in to GitHub with gh's login (`gh auth login`). `gh auth
  # setup-git` cannot add this itself: the git config is a read-only Home
  # Manager file.
  ghHelper = {helper = ["" "${pkgs.gh}/bin/gh auth git-credential"];};
in {
  programs.git = {
    enable = true;
    settings = {
      init.defaultBranch = "main";
      pull.rebase = true;
      credential."https://github.com" = ghHelper;
      credential."https://gist.github.com" = ghHelper;
    };
  };
}
