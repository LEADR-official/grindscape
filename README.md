# GrindScape

A tiny top-down 2D browser game built in Godot 4 as a real-world integration example for the [LEADR](https://www.leadr.gg) leaderboard SDK.

Mine ore, fight a skeleton, try not to die. Your stats get submitted to multiple LEADR leaderboards on death.

## Why This Exists

Most SDK examples are contrived. GrindScape is a playable (if deliberately minimal) game that demonstrates how LEADR fits into an actual game loop: tracking multiple metrics during gameplay, submitting them to different leaderboards on a single event, and displaying the results.

## What It Demonstrates

- **Multi-metric submission:** ore count, XP, skeleton kills, survival time, and derived stats like ore-per-minute are each submitted to separate leaderboards from one game session.
- **Godot SDK integration:** drop-in usage of the LEADR Godot plugin, wired into a real game-over flow.
- **Leaderboard display:** fetching and showing board data in-game.

## Play It

[Play on itch.io](https://TODO) - runs in your browser, no install needed.

## Run It Locally

Requires Godot 4.x.

```
git clone https://github.com/LEADR-Official/grindscape.git
cd grindscape
# Open project.godot in the Godot editor, hit Play
```

## Design doc

Plan and design intentions are detailed in `./plans/grindscape_design_doc.md`.

______________________________________________________________________

## Need Help?

- [Documentation](https://docs.leadr.gg)
- [Discord](https://discord.gg/RMUukcAxSZ)
- [Report an issue](https://github.com/LEADR-official/leadr-oss/issues)

______________________________________________________________________

*Built with ❤️ for the indie game dev community*
