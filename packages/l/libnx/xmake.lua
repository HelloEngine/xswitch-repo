package("libnx")
    set_description("Nintendo Switch AArch64-only userland library.")
    set_homepage("http://github.com/switchbrew")
    add_urls("https://github.com/HelloEngine/libnx.git")
    add_deps("switch-tools")

    on_install("cross@windows", "cross@msys", function(package)
        local configs = {}
--         io.writefile("nx/switch.specs", [[
-- %rename link                old_link

-- *link:
-- %(old_link) -T %:getenv(LIBNX /switch.ld) -pie --no-dynamic-linker --spare-dynamic-tags=0 --gc-sections -z text -z nodynamic-undefined-weak --build-id=sha1 --nx-module-name

-- *startfile:
-- crti%O%s crtbegin%O%s --require-defined=main]])

--         io.writefile("xmake.lua", string.format([[
--             add_rules("mode.debug", "mode.release")
--             set_plat("cross")
--             --set_version("%s")
--             toolchain("aarch64-none-elf")
--                 set_kind("cross")
--                 on_load(function (toolchain)
--                     toolchain:load_cross_toolchain()
--                 end)
--             toolchain_end()

--             add_repositories("xswitch-repo https://github.com/HelloEngine/xswitch-repo.git main")
--             add_requires("devkit-a64", "bin2s")
--             target("libnx")
--                 set_basename("nx")
--                 set_toolchains("aarch64-none-elf@devkit-a64")
--                 set_kind("static")
--                 add_packages("bin2s")
--                 add_defines("LIBNX_NO_DEPRECATION", "__SWITCH__")
--                 add_files("nx/source/**.s","nx/source/**.c")
--                 add_includedirs("nx/data/","nx/include/", "nx/include/switch/", "nx/external/bsd/include/")
--                 on_config(function(target)
--                     local binfile = os.curdir() .. "/nx/data/default_font.bin"
--                     assert(os.exists(binfile))
--                     local outdata, errdata
--                     if is_subhost("msys") then
--                         outdata, errdata = os.iorun("bin2s " .. binfile)
--                     else
--                         outdata, errdata = os.iorun("bin2s.exe " .. binfile)
--                     end
--                     io.writefile("nx/data/default_font_bin.s", outdata)
--                     io.writefile("nx/data/default_font_bin.h", [=[
--                         #pragma once
--                         extern const unsigned char default_font_bin[];
--                         extern const unsigned char default_font_bin_end[];
--                         extern const unsigned int default_font_bin_size;
--                     ]=])
--                     target:add("files", "nx/data/**.s")
--                 end)
--                 on_install(function(target)
--                     os.cp(target:targetfile(), target:installdir() .. "/lib/")
--                     os.cp(target:scriptdir() .. "/nx/include", target:installdir())
--                     os.cp(target:scriptdir() .. "/nx/external/bsd/include", target:installdir())
--                     os.cp(target:scriptdir() .. "/nx/default_icon.jpg", target:installdir())
--                     os.cp(target:scriptdir() .. "/nx/switch.specs", target:installdir())
--                     os.cp(target:scriptdir() .. "/nx/switch.ld", target:installdir())
--                 end)
--                 add_cflags("-g", 
--                     --"-Wall", 
--                     "-Werror",
--                     "-ffunction-sections", 
--                     "-fdata-sections", 
--                     "-march=armv8-a+crc+crypto", 
--                     "-mtune=cortex-a57",
--                     "-mtp=soft",
--                     "-fPIC", 
--                     "-ftls-model=local-exec")
--                 add_cxxflags("-g", 
--                     --"-Wall", 
--                     "-Werror",
--                     "-ffunction-sections", 
--                     "-fdata-sections", 
--                     "-march=armv8-a+crc+crypto", 
--                     "-mtune=cortex-a57",
--                     "-mtp=soft",
--                     "-fPIC", 
--                     "-ftls-model=local-exec",
--                     "-fno-rtti",
--                     "-fno-exceptions",
--                     "-std=gnu++11")
--                 add_asflags("-g",
--                     "-march=armv8-a+crc+crypto", 
--                     "-mtune=cortex-a57",
--                     "-mtp=soft",
--                     "-fPIC", 
--                     "-ftls-model=local-exec")
--                 if is_mode("debug") then
--                     set_suffixname("d")
--                 end
--         ]], package:version_str()))
        import("package.tools.xmake").install(package, configs)
    end)

    on_load(function(package)
        package:addenv("LIBNX", package:installdir())
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