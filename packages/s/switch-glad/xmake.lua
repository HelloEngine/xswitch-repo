package("switch-glad")
    set_description("Switch port of an autogenerated OpenGL 4.3 loader")
    set_homepage("https://github.com/HelloEngine/switch-glad")

    add_versions("1.0.0", "1000f80fcc559e0ec4ce3ef808620fd0266ef519a73ace72ffe1c18c36943b90")
    add_versions("1.0.1", "a8834e28ce5a5ce3e0e6678c32203f1c0a411fec0f8a00a87988a58c5c24c469")
    add_urls("https://github.com/HelloEngine/switch-glad/releases/download/$(version)/switch-glad.zip")

    add_deps("switch-mesa")
    add_links("EGL", "glapi")

    on_install("cross@windows", "cross@msys", function(package)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        os.cp("xmake.lua", package:installdir() .. "/xmake.lua")
    end)

    on_fetch("cross@windows", "cross@msys", function(package, opt)
        local result = {}
        if is_mode("debug") then
            result.linkdirs = package:installdir("lib/debug")
            result.links = "gladd"
        else
            result.linkdirs = package:installdir("lib/release")
            result.links = "glad"
        end
        result.includedirs = package:installdir("include")
        result.version = package:version_str()
        return result
     end)
package_end()
