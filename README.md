# GrindScape

A tiny top-down 2D browser game built in Godot 4 as a real-world integration example for the [LEADR](https://www.leadr.gg) leaderboard SDK.

Mine ore, fight a skeleton, try not to die. Your stats get submitted to multiple LEADR leaderboards on death.

## Why This Exists

Most SDK examples are contrived. GrindScape is a playable (if deliberately minimal) game that demonstrates how LEADR fits into an actual game loop: tracking multiple metrics during gameplay, submitting them to different leaderboards on a single event, and displaying the results.

## What It Demonstrates

- **Godot SDK integration:** drop-in usage of the LEADR Godot plugin, wired into a real game-over flow.
- **Score submission:** ore count, XP, skeleton kills, survival time, and derived stats like ore-per-minute are each submitted to separate leaderboards from one game session.
- **Leaderboard display (coming soon):** fetching and showing board data in-game.

## Play It

[Play on itch.io](https://TODO) - runs in your browser, no install needed.

## Run It Locally

Requires Godot 4.x.

```
git clone https://github.com/LEADR-Official/grindscape.git
cd grindscape
# Open project.godot in the Godot editor, hit Play
```

## Credits

- Inspired by: [Oldschool Runescape](https://oldschool.runescape.com/) by [Jagex](https://www.jagex.com/)
- Design and build: [Barney Jackson](https://github.com/barneyjackson)
- Art, assets: [Tiny Swords](https://pixelfrog-assets.itch.io/tiny-swords) by [Pixel Frog](https://pixelfrog-assets.itch.io/)
- SFX:
  - [Impact Sounds](https://kenney.nl/assets/impact-sounds) from [Kenney](https://www.kenney.nl)
  - [Interface Sounds](https://kenney.nl/assets/interface-sounds) from [Kenney](https://www.kenney.nl)
  - [Rock smash](https://pixabay.com/sound-effects/nature-rock-smash-6304/) by [freesound_community](https://pixabay.com/users/freesound_community-46691455/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=6304) from [Pixabay](https://pixabay.com//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=6304)
  - [Drop coin](https://pixabay.com/sound-effects/film-special-effects-drop-coin-384921/) by [Crunchpix Studio](https://pixabay.com/users/freesound_crunchpixstudio-49769582/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=384921) from [Pixabay](https://pixabay.com/sound-effects//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=384921)
  - [Knife Stab Sound Effect](https://pixabay.com/sound-effects/film-special-effects-knife-stab-sound-effect-36354/) by [freesound_community](https://pixabay.com/users/freesound_community-46691455/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=36354) from [Pixabay](https://pixabay.com/sound-effects//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=36354)
  - [Attack Sound 1](https://pixabay.com/sound-effects/film-special-effects-attack-sound-1-384908/) by [Crunchpix Studio](https://pixabay.com/users/freesound_crunchpixstudio-49769582/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=384908) from [Pixabay](https://pixabay.com//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=384908)
  - [Game Die](https://pixabay.com/sound-effects/film-special-effects-086398-game-die-81356/) by [freesound_community](https://pixabay.com/users/freesound_community-46691455/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=81356) from [Pixabay](https://pixabay.com//?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=81356)
- Music: ["Magic Fantasy Fairy Tale Music"](https://pixabay.com/music/fantasy-dreamy-childrens-magic-fantasy-fairy-tale-music-431276/) by [Ievgen Poltavskyi](https://pixabay.com/users/hitslab-47305729/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=431276) from [Pixabay](https://pixabay.com/music/?utm_source=link-attribution&utm_medium=referral&utm_campaign=music&utm_content=431276)
- Font:

______________________________________________________________________

## Need Help?

- [Documentation](https://docs.leadr.gg)
- [Discord](https://discord.gg/RMUukcAxSZ)
- [Report an issue](https://github.com/LEADR-official/leadr-oss/issues)

______________________________________________________________________

*Built with ❤️ for the indie game dev community*
