# GAdmin - Plugin Simplifying the Work of Administrators on Gambit-RP

**GAdmin is a forever free and open-source modification for San Andreas: Multiplayer.
It is designed to improve the user experience while administrating on the Gambit Role-Play server.**

The modification introduces new features for easy administration, for example:

- ImGui interface in spectator mode: player statistics, player's pressed keys, and buttons to interact
  with a player you're spectating (can be customized).
- Cheats: AirBreak, ClickWarp, Tracers, and WallHack.
- Statistics: online for a certain period of time, answers (`/ans`), punishments (`/ban`, `/kick`, etc.),
  and much more.
- FarChat: a window displaying almost all messages on the server, including actions (`/me`, `/do`, etc.).

These are just some of the many features available to you. Any feature can be configured in the way
you want: every setting has its own configuration options.

## Building the Code

The project is written using C++23 standards and is only for the GCC (MinGW) compiler, either version
`14.2.0` or any later version. To build the code, you will also need to have CMake version 4.0.0. Note
that we have two targets that will be compiled: `gadmin-loader.asi` (loads `gadmin.dll` and checks for
available updates to make suggestions to install if there are any) and `gadmin.dll` (if you want, you can
rename it to `gadmin.asi` and remove the loader to load independently from it).

```bash
# Configure the project.
cmake -B build/

# Compile source files.
cmake --build build/

# Output: gadmin.dll gadmin-loader.asi
ls build/bin
```

## Installation

In order to use the plugin, you need to have the original GTA: San Andreas (`1.0 US`), its online
modification (`SA:MP v0.3.7-(R1/R3/R5/DL-1)`), a configured ASI loader, and two files from the latest release:
`gadmin-loader.asi` and `gadmin.dll`. Put these two files in the directory where your game is installed.

## Contributing

There are many ways in which you can participate in this project, for example:

- [Submit bugs and feature requests](https://github.com/Vadim-Kamalov/GAdmin/issues) and help us verify them
  as they are checked in.
- [Review source code changes](https://github.com/Vadim-Kamalov/GAdmin/pulls).
- Review the code documentation and make pull requests for anything from typos to additional and new content.

Every contributor has the right to receive a color for their nickname in the game chat (`/a`): you can see the
list of colors [here](https://github.com/Vadim-Kamalov/GAdmin/blob/main/nickname-colors.json). Feel free to
contribute.

## Support the Project

GAdmin is 100% community-built. Please become a part of keeping our project alive and thriving with a donation
if you believe in the project. If you want, you can contact the sole maintainer: [@defaultzone](https://github.com/defaultzone).

> Project supporters have the right to receive a color for their nickname in the game chat (/a).

Thanks!

## License

This project is licensed under the GNU General Public License v3.0 (GPLv3). You are free to use, modify, and
distribute the software in accordance with the terms of this license. For more details, see the
[LICENSE](https://github.com/Vadim-Kamalov/GAdmin/blob/main/LICENSE) file or visit the
[GNU GPLv3 website](https://www.gnu.org/licenses/gpl-3.0.html).

Copyright (C) 2023-2025 The Contributors.
