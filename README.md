# About

NinjaFrog is my first real game and has been mainly a learning exercise, to better understand Heaps, Haxe, LDtk and Deepnight's gamebase code and libraries.
It's not a perfect game by any stretch, but it was fun and I enjoyed every bug, issue and of course every little success.

This is a small puzzle game, heavely inspired (something more than ispired I admit) by the beautiful Pixel Frog art.
His demo levels are so nice, complete and full of ideas, that I couldn't resist the urge to try to replicate on my own at least of fraction of them.
Pixel Adventure's demo is more fun than my game, but I saw this grow from a single sprite to what you can see now, and I'm proud of it :)


# Building

Requires Haxe 4.3, HashLink 1.16 and the libraries listed below.

- Linux (OpenGL, SDL): `haxe build.opengl.hxml`, then `hl bin/client.hl`
- Windows (DirectX): `haxe build.directx.hxml`
- Debug build: `haxe build.dev.hxml` (OpenGL + `-debug`)
- Web: `haxe build.js.hxml`, then open `js.html`

The original 2021 version (Haxe 4.2.1, LDtk 0.9.3) is kept on the [`legacy`](https://github.com/di-effe/NinjaFrog/tree/legacy) branch.

# Updates
2026.10.09

Ported to current Haxe, HashLink, Heaps and Deepnight's libraries. The game plays the same.

- LDtk 1.5.3 (world.ldtk converted by the editor)
- Haxe 4.3.7, HashLink 1.16 (SDL3)
- heaps: [git, deepnight fork e5a3d382]
- deepnightLibs: [git c830882]
- ldtk-haxe-api: [git 22d7ee2]
- castle: [git 261c8db]
- hlsdl: from the HashLink 1.16 sources
- build files renamed to the current gameBase layout (`_base.hxml`, `build.*.hxml`)
- old deepnightLibs classes (`Color`, `Controller`) now come from its `dn.legacy` package

2021.05.28

- LDtk 0.9.3
- 4.2.1+bf9ff69 
- castle: [git 1.6.1 ]
- deepnightLibs: [git 1.0.59]
- format: [3.5.0]
- heaps: [git 1.9.1]
- hldx: [1.10.0]
- hlopenal: [1.5.0]
- hlsdl: [1.10.0]
- ldtk-haxe-api: [git 0.9.3-rc.1]
- redistHelper: [0.4.10]

# Credits

## Art and Pixel Adventure demo
https://pixelfrog-store.itch.io/pixel-adventure-1
https://pixelfrog-store.itch.io/pixel-adventure-2

## Font
https://heraldod.itch.io/bitmap-fonts

## Sounds
https://sidearm-studios.itch.io/ultimate-sound-fx-bundle

## Deepnight's gameBase
https://github.com/deepnight/gameBase/

## Level design done with
https://ldtk.io/

