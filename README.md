# MugenMatrix
Mugen Matrix — A high-performance, offline 1v1 2D local multiplayer fighting game built in Godot. Features a robust Finite State Machine (FSM) architecture, frame-accurate decoupled hitboxes/hurtboxes, and custom-sliced retro arcade sprite animation pipelines.

On launch, choose **BATTLE** to open character select or **QUIT** to close the game. Player 1 uses **WASD** and confirms with **U**; Player 2 uses the **arrow keys** and confirms with **1**. Both players must confirm before the match starts. Goku is the only selectable character at present.

The menu's extracted DBZ screenpack art, music, and Tempest Narrow TrueType font are in `assets/ui/mugen/`, so the original `DBZ MUGEN` folder is not needed to run the menu. Godot does not import MUGEN `.sff` archives or its bitmap `.fnt` fonts as UI fonts; the screenpack sprites are exported as PNG, and the bundled TTF is used for text. The original screenpack's configured bitmap fonts would need converting to a Godot font/atlas to reproduce those exact glyphs. Edit the title screen in `scenes/menu.tscn` and the reusable character-select child scene in `scenes/character_select.tscn`; `scripts/Menu.gd` handles input, ready status, music, and scene transitions.

The fight camera follows the midpoint between both players, zooms from 1.2 down to 0.7 as they separate, clamps its horizontal view to the arena walls, and keeps the bottom of its view at world y=0. Its tuning and wall references are editable on the Camera2D node in `scenes/game.tscn`.
