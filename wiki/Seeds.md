# Seeds for epic runs

PokéBot comes with a built-in run recording feature that takes advantage of random number seeding to reproduce runs in their entirety. Any time the bot resets or beats the game, it logs a number to the Lua console that is the seed for the run. This seed allows you to easily share the run with others. A screenshot is also saved to the `Gameboy\Screenshots` folder in the `Bizhawk` directory.

### [Pokémon Red](https://github.com/kylecoburn/PokeBot/blob/master/wiki/red/Seeds.md)

### [Pokémon Yellow](https://github.com/kylecoburn/PokeBot/blob/master/wiki/yellow/Seeds.md)

To reproduce any of these runs, set [`CUSTOM_SEED` in `main.lua`](https://github.com/kylecoburn/PokeBot/blob/27aa1dcd2cec1bbe25607fa346836f63b349ad5f/main.lua#L5) to the seed number, `NIDORAN_NAME` to the matching name, and run the bot.

Have you found a seed with a great time, using the bot’s default settings, on the latest version? [Let us know](https://github.com/kylecoburn/PokeBot/issues/4), and we’ll add it to the list!
