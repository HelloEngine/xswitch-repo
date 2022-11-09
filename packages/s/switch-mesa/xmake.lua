package("switch-mesa")
    set_description("The 3D Graphics Library")
    set_homepage("https://github.com/HelloEngine/mesa")

    add_versions("1.0.0", "4fdbe5f6012be5cf8c96231dcc9de72729394f5638ee43e464946588dd7fd3f0")
    add_urls("https://github.com/HelloEngine/mesa/releases/download/$(version)/switch-mesa.zip")

    on_install("cross@windows", "cross@msys", function(package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("share", package:installdir())
        os.cp("xmake.lua", package:installdir() .. "/xmake.lua")
    end)
package_end()