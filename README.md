# dotfiles


This repository provides a single line install to a variety of dotfiles.


## Deploying (option 1 - install script)

The single line that you need to run:

```

curl https://raw.githubusercontent.com/abassel/dotfiles/master/boot.sh | bash


```

## Deploying (option 2  - git bare repo)

```

alias config='git --git-dir=$HOME/dotfiles --work-tree=$HOME'
git clone --bare git@github.com:abassel/dotfiles.git $HOME/dotfiles
config config --local status.showUntrackedFiles no
config checkout

```

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