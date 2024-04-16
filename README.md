<h1 align="center">
  <br>
  <a href="https://www.abassel.com" width="200"><img src="/.config/dotfiles.svg" alt="" width="200"></a>
  <br>
  DotFiles
  <br>
</h1>

<h4 align="center"> DotFiles are meant to be copied!</h4>

##### 1 - Deploying with git bare repo

```

alias config='git --git-dir=$HOME/dotfiles --work-tree=$HOME'
git clone --bare git@github.com:abassel/dotfiles.git $HOME/dotfiles
config config --local status.showUntrackedFiles no
config checkout

```

## TODO :zap:
- implement tmux sessionizer from ellijah manor - https://github.com/elijahmanor/dotfiles/blob/becb603445247727b37c2f66a88ca5d60eeff7fb/bin/bin/tmux-sessionizer

## References :notebook:
- [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles)
- [jessfraz dotfiles](https://github.com/jessfraz/dotfiles)
- [DT's youtube video to manage dotfiles](https://www.youtube.com/watch?v=tBoLDpTWVOM)
- [The best way to store your dotfiles: A bare Git repository](https://www.atlassian.com/git/tutorials/dotfiles)
- [Danny Cosson Dotfiles](https://github.com/dcosson/dotfiles)
- [mattjmorrison's Dotfiles](https://github.com/mattjmorrison/dotfiles)
- [alrra's dotfiles](https://github.com/alrra/dotfiles)
- [ryanoasis' dotfiles](https://github.com/ryanoasis/dotfiles)
- [dotfiles](https://dotfiles.github.io)
- [readme.md templates](https://www.readme-templates.com/)