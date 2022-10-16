package("libnx")
    set_description("Nintendo Switch AArch64-only userland library.")
    set_homepage("http://github.com/switchbrew")
    --add_urls("http://github.com/switchbrew/libnx/archive/v$(version).tar.gz")
    add_urls("https://github.com/HelloEngine/libnx.git")

    --add_versions("4.2.1", "6be7e3f1fe1768d101bc832348cd4369b25dee35e0551913b80a12fb596b021e")

    add_deps("bin2s")

    on_install("mingw@msys", "cross@msys", "linux@msys", function(package)
        local configs = {}
        io.writefile("xmake.lua", string.format([[
            add_repositories("xswitch-repo https://github.com/HelloEngine/xswitch-repo.git main")

            toolchain("aarch64-none-elf")
                set_description("Nintendo Switch aarch64-none-elf toolchain")
                set_homepage("https://github.com/devkitPro")
                set_kind("cross")
                on_load(function (toolchain)
                    toolchain:load_cross_toolchain()
                end)
            toolchain_end()

            add_requires("devkit-a64")

            set_version("%s")
            set_basename("nx")
            target("libnx")
                set_toolchains("aarch64-none-elf@devkit-a64")
                set_kind("static")
                add_defines("LIBNX_NO_DEPRECATION", "__SWITCH__")
                add_files("nx/source/**.s","nx/source/**.c")
                add_includedirs("nx/data/","nx/include/", "nx/include/switch/", "nx/external/bsd/include/")
                on_install(function(target)
                    os.cp(target:targetfile(), target:installdir() .. "/lib/")
                    os.cp(target:scriptdir() .. "/nx/include", target:installdir())
                    os.cp(target:scriptdir() .. "/nx/external/bsd/include", target:installdir())
                    os.cp(target:scriptdir() .. "/nx/default_icon.jpg", target:installdir())
                end)
                add_cflags("-g", 
                    "-Wall", 
                    "-Werror",
                    "-ffunction-sections", 
                    "-fdata-sections", 
                    "-march=armv8-a+crc+crypto", 
                    "-mtune=cortex-a57",
                    "-mtp=soft","-fPIC", 
                    "-ftls-model=local-exec")
                add_cxxflags("-g", 
                    "-Wall", 
                    "-Werror",
                    "-ffunction-sections", 
                    "-fdata-sections", 
                    "-march=armv8-a+crc+crypto", 
                    "-mtune=cortex-a57",
                    "-mtp=soft","-fPIC", 
                    "-ftls-model=local-exec",
                    "-fno-rtti",
                    "-fno-exceptions",
                    "-std=gnu++11")
                add_asflags("-g",
                    "-march=armv8-a+crc+crypto", 
                    "-mtune=cortex-a57",
                    "-mtp=soft","-fPIC", 
                    "-ftls-model=local-exec")
                if is_mode("debug") then
                    set_suffixname("d")
                end

        ]], package:version_str()))
        local binfile = string.format("%s/nx/data/default_font.bin", os.curdir())
        assert(os.exists(binfile))
        local outdata, errdata = os.iorun(string.format("bin2s %s", binfile))
        io.writefile("nx/data/default_font_bin.s", outdata)
        io.writefile("nx/data/default_font_bin.h", [[
            #pragma once
            extern const unsigned char default_font_bin[];
            extern const unsigned char default_font_bin_end[];
            extern const unsigned int default_font_bin_size;
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_load(function(package)
    end)

    on_test(function(package)
        -- assert(package:check_cxxsnippets({test = [[
        --     #include "switch.h"
        --     #include <assert.h>
        --     static void test() 
        --     {
        --         assert(R_SUCCEEDED(1));
        --     }
        -- ]]}))
    end)
package_end()