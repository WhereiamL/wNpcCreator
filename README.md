# wNpcCreator

A framework-agnostic FiveM NPC creator menu. Place, configure, and manage
interactive NPCs in-game — all persisted to your database.

Preview: [YouTube](https://www.youtube.com/watch?v=MfmhHy9OT7g)

## Features

- Works with **ESX**, **QBCore**, and **QBox** (auto-detected).
- **SQL persistence** via oxmysql — no more flat JSON files.
- Distance-based spawning using `lib.points` for performance.
- Optional `ox_target` interaction and floating DrawText with a configurable key.
- Job/grade restrictions per NPC.
- In-game placement preview with rotation.
- Automatic one-time migration of an existing `npcData.json` into SQL.

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [oxmysql](https://github.com/overextended/oxmysql)
- [ox_target](https://github.com/overextended/ox_target) *(optional — only for target interaction)*

## Installation

1. Drop the resource into your server and `ensure wNpcCreator`.
2. The `wnpc_creator` table is created automatically on first start.
3. Use `/npcadd` in-game (requires the `wnpc.admin` ace permission or a group
   listed in `Config.AdminGroups`).

## Configuration

See `config.lua` for the command name, framework override, admin groups, ace
permission, spawn/interaction distances, and default animation.

## Support

[Discord](https://discord.gg/s5yB3JYZsn)

![Thumbnail](https://github.com/WhereiamL/wNpcCreator/assets/84282589/4c15c6a3-c2c6-4cf9-adac-2355a4d98020)
