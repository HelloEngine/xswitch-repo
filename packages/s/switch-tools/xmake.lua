package("switch-tools")
    set_description("Nintendo Switch tools")
    set_homepage("https://github.com/HelloEngine/switch-tools")
    add_versions("1.0.0", "16f98244e49d40320928ee0a8c13d779d8ea3be7c2b7b90adfd09e859b04da3f")
    add_urls("https://github.com/HelloEngine/switch-tools/releases/download/$(version)/switch-tools.zip")

    on_load(function(package)
        package:addenv("SWITCH_TOOLS", package:installdir())
    end)

    on_install("cross@windows", "cross@msys", function(package)
        os.cp("bin", package:installdir())
        os.cp("xmake.lua", package:installdir() .. "/xmake.lua")
    end)

    on_test(function(package)
        assert(os.exists(package:installdir() .. "/bin/nacptool.exe"))
    end)
package_end()