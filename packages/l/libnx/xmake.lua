package("libnx")
    set_description("Nintendo Switch AArch64-only userland library.")
    set_homepage("http://github.com/switchbrew")

    -- add_urls("https://github.com/HelloEngine/libnx.git")
    -- add_deps("switch-tools")
    -- on_install("cross@windows", "cross@msys", function(package)
    --     local configs = {}
    --     import("package.tools.xmake").install(package, configs)
    -- end)

    add_versions("1.0.0", "153b032d8369cd55e5c031ad0471c695045778a4d5fcca506b9018445a98026a")
    add_versions("1.0.1", "fa164316515f3a658571f1a8e2354eae0526bec5a64ef275ff4f18ef2bb11f6d")
    add_urls("https://github.com/HelloEngine/libnx/releases/download/$(version)/libnx.zip")

    add_deps("devkit-a64")
    add_deps("switch-tools")

    on_load(function(package)
        package:addenv("LIBNX", package:installdir())
    end)

    on_install("cross@windows", "cross@msys", function(package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("rules", package:installdir())
        os.cp("default_icon.jpg", package:installdir() .. "/default_icon.jpg")
        os.cp("xswitch.ld", package:installdir() .. "/xswitch.ld")
        os.cp("xswitch.specs", package:installdir() .. "/xswitch.specs")
        os.cp("xmake.lua", package:installdir() .. "/xmake.lua")
    end)

    on_fetch("cross@windows", "cross@msys", function(package, opt)
        local result = {}
        if is_mode("debug") then
            result.linkdirs = package:installdir("lib/debug")
            result.links = "nxd"
        else
            result.linkdirs = package:installdir("lib/release")
            result.links = "nx"
        end
        result.includedirs = package:installdir("include")
        result.version = package:version_str()
        return result
     end)
package_end()