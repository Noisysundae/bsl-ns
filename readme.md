# Noisysundae's BSL Extension (BSL-NS)

Version: **0.2**  
Release Date: 24 Apr 2023

## Credits

Shout-out to **[CaptTatsu](https://bitslablab.com/)** for the obvious shader this one is based on, [BSL Shaders](https://modrinth.com/shader/bsl-shaders)!

## BSL-NS Features / Changes

### Extended BSL Shaders Settings

- **New!** Smooth World Time Animation
	- No longer locked at 20 FPS (Game tick resolution).
	- New effect on pausing / resuming the game!
- Color Grading
	- Maximum Channel Values
	- (In BSL-NS Menus) Single-Screen Adjustment UI Layout
- Outline Intensity (for Colored and Dungeon Style Cel-Shading)

### BSL-NS Features

- **New!** Climatic Animation
	- Waving objects and water scale based on the environment (biome, weather, etc.).
	- Configurable via a global toggle and weight sliders.
- Improved Pattern Dithering
	- Configurable Pattern Steps and Scale
	- Overrides on the original BSL Shaders' effects can be toggled on or off.
- Camera Fade
	- Dithers out objects close to the camera (most entities / blocks with no collision).
	- Configurable Distance (First / Third Person)

### Other Changes in This Version

- Upgraded base BSL Shaders to version 8.2.03.
- Added an attached preset (settings import) used by...me.
	- Includes only non-performance settings.
- Removed entity backface culling on camera fade.

## Disclaimer

> "Since I mostly modified this shader pack for personal enjoyment, I can't guarantee compatibility support or any other kind of maintenance; BSL-NS was made on a whim, but I'll try to merge future versions of BSL Shaders into this, whenever I'm available."  
— The manager of Noisysundae