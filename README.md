# xswitch-repo

It is used to cross compile Nintendo Switch applications on windows or msys2

# how to use those packages to build nro

---

1. Xmake 2.7.2 and above is required
2. Please set the platform to cross!!!!!!!!

---

xmake.lua:

```
set_xmakever("2.7.2")
set_plat("cross")

toolchain("aarch64-none-elf")
    set_kind("cross")
    on_load(function (toolchain)
        toolchain:load_cross_toolchain()
    end)
toolchain_end()

add_repositories("xswitch-repo https://github.com/HelloEngine/xswitch-repo.git main")
add_requires("devkit-a64","libnx")

target("test")
    set_toolchains("aarch64-none-elf@devkit-a64")
    add_packages("libnx")
    add_rules("@libnx/switch")
    set_kind("binary")
```

command:

```
xmake f -p cross
xmake build
```

# packages

## devkit-a64

Cross compilation toolchain aarch64-none-elf, download from pacman package manager of devkitPro, usage:

```
toolchain("aarch64-none-elf")
    set_kind("cross")
    on_load(function (toolchain)
        toolchain:load_cross_toolchain()
    end)
toolchain_end()

add_repositories("xswitch-repo https://github.com/HelloEngine/xswitch-repo.git main")
add_requires("devkit-a64")

target("test")
    set_toolchains("aarch64-none-elf@devkit-a64")
```

## devkit-a64-gdb

Debugger of toolchain aarch64-none-elf, download from pacman package manager of devkitPro, usage:

```
add_repositories("xswitch-repo https://github.com/HelloEngine/xswitch-repo.git main")
add_requires("devkit-a64-gdb")
```

## bin2s

Convert binary files to GCC assembly modules.

## switch-tools

Toolset of Nintendo Switch, download from pacman package manager of devkitPro

## libnx

Library for Switch Homebrew, package generation depends on devkit-a64 and bin2s, package depends on switch-tools, usage:

```
add_repositories("xswitch-repo https://github.com/HelloEngine/xswitch-repo.git main")
add_requires("libnx")

target("test")
    add_packages("libnx")
    add_rules("@libnx/switch")
```
