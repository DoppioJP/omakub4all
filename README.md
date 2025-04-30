# Omakub for All!

We all know the one-line pitch for Omakub:
> Turn a fresh Ubuntu installation into a fully-configured, beautiful, and modern web development system by running a single command.

It is amazing. It is beautiful, useful, aesthetically pleasing. There is a catch though: "Ubuntu on x86 only".

The goal in this very fork is to bring Omakub to other 3 platforms:
- Ubuntu on ARM
- macOS on ARM
- macOS on x86

## Why?

While I could take all my Apple computers, sell them and get a Framework laptop - it didn't happen yet. In the meantime I want to try experiencing Omakub setup. Here are the options:
1. Take an old Apple laptop with x86 processor and install Ubuntu Linux on it.

   Works like a charm. Only need to add more memory and SSD...
   
2. M series (Apple Silicon, a.k.a ARM) laptop with a lot of memory. Why not use that power and have Omakub based development environment fly?

   a. VirtualBox with Ubuntu Linux - with some tweeks it works super nice
   
      Currently achieved working version in https://github.com/DoppioJP/omakub-arm, but it is based on an older Omakub 1.1.3 from Aug 2024 (200 commits behind)

   b. Direct setup on macOS

      Ubuntu Linux on VirtualBox works well, but that can be sometimes moody. VirtualBox crashes, access to host files not always works as intended.
      Having on macOS at least the Terminal (Alacritty + Zellij) development environment with the beautiful theme could be something already.
      That is what this fork aims for, especially in the [`macos-tui`](https://github.com/DoppioJP/omakub4all/tree/macos-tui) branch.

      Not everything will get installed if we only do the `terminal` installation, because the Alacritty part is within the `desktop` part. [`macos`](https://github.com/DoppioJP/omakub4all/tree/macos) branch installs everything proposed in the Omakase way. 

4. macOS on Intel

   I haven't tried that yet, but thanks to relying on [Homebrew](https://brew.sh) package manager for macOS, it should just work from `macos*` branches. 

## To do

- [ ] Add some basic settings for Alacritty + Zellij which are needed to have it usable on macOS due to a different behaviour of tiling. For now opening full screen with font-size 16 is the best solution
- [ ] Move [omakub-arm](https://github.com/DoppioJP/omakub-arm) to [`ubuntu-arm`](https://github.com/DoppioJP/omakub4all/tree/ubuntu-arm) branch after rebasing
- [ ] Make [`macos-tui`](https://github.com/DoppioJP/omakub4all/tree/macos-tui) complete with all necessary desktop apps included
- [ ] Possibly there will be no need for separa `macos` and `macos-tui` branches. Relying on env variable `OMAKUB_MACOS_TUI_ONLY` might be enough
- [ ] Figure out how the rebase to the latest Omakub will work
- [ ] Make it an extension for Omakub

