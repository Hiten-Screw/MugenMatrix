# MugenMatrix
Mugen Matrix — A high-performance, offline 1v1 2D local multiplayer fighting game built in Godot. Features a robust Finite State Machine (FSM) architecture, frame-accurate decoupled hitboxes/hurtboxes, and custom-sliced retro arcade sprite animation pipelines.

On launch, choose **BATTLE** to open character select or **QUIT** to close the game. Player 1 uses **WASD** and confirms with **U**; Player 2 uses the **arrow keys** and confirms with **1**. Both players must confirm before the match starts. Goku is the only selectable character at present.

The fight camera follows the midpoint between both players, zooms from 1.2 down to 0.7 as they separate, clamps its horizontal view to the arena walls, and keeps the bottom of its view at world y=0. Its tuning and wall references are editable on the Camera2D node in `scenes/game.tscn`.
