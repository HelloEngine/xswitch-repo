package("drm_nouveau")
    set_description("Interface between mesa/nouveau and Nintendo Switch Nvidia GPU driver")
    set_homepage("https://github.com/HelloEngine/libdrm_nouveau")
    add_versions("1.0.0", "20ffec756e32d10cdd93956dca44891c31acf9c265611d8dbafaf1fd73f16c2c")
    add_versions("1.0.1", "7ae70ed89b431bb74bfb3d192acd31250640f829693afdffde3918a035ab4e6a")
    add_urls("https://github.com/HelloEngine/libdrm_nouveau/releases/download/$(version)/drm_nouveau.zip")

    add_deps("libnx")
    if is_mode("debug") then
        add_links("nxd")
    else 
        add_links("nx")
    end

    on_install("cross@windows", "cross@msys", function(package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("xmake.lua", package:installdir() .. "/xmake.lua")
    end)

    on_fetch("cross@windows", "cross@msys", function(package, opt)
        local result = {}
        if is_mode("debug") then
            result.linkdirs = package:installdir("lib/debug")
            result.links = "drm_nouveaud"
        else
            result.linkdirs = package:installdir("lib/release")
            result.links = "drm_nouveau"
        end
        result.includedirs = package:installdir("include")
        result.version = package:version_str()
        return result
     end)

    -- add_urls("https://github.com/HelloEngine/libdrm_nouveau.git")

    -- add_deps("libnx")

    -- on_install("cross@windows", "cross@msys", function(package)
    --     local configs = {}
    --     import("package.tools.xmake").install(package, configs)
    -- end)

    -- on_test(function(package)
    --     assert(package:has_cxxincludes("nouveau.h"))
    -- end)
package_end()
