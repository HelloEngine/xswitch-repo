package("drm_nouveau")
    set_description("Interface between mesa/nouveau and Nintendo Switch Nvidia GPU driver")
    set_homepage("https://github.com/HelloEngine/libdrm_nouveau")
    add_versions("1.0.0", "20ffec756e32d10cdd93956dca44891c31acf9c265611d8dbafaf1fd73f16c2c")
    add_urls("https://github.com/HelloEngine/libdrm_nouveau/releases/download/$(version)/drm_nouveau.zip")

    on_install("cross@windows", "cross@msys", function(package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("xmake.lua", package:installdir() .. "/xmake.lua")
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