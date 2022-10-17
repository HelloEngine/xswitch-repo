local versionUrls = {
    ["1.0.0"] = "switch-tools-1.12.0-1-windows_x86_64.pkg.tar.xz"
}

package("switch-tools")
    add_versions("1.0.0", "91fa3e77d39840e83a6a0a1d7d1e5968bcb066edce9b3cdff917fb928dc591ff")
    set_description("Nintendo Switch tools")
    set_homepage("https://github.com/devkitPro")
    add_urls("https://wii.leseratte10.de/devkitPro/switch/$(version)", {version = function(version)
        return versionUrls[version:shortstr()]
    end})

    on_load(function(package)
        package:addenv("SWITCH_TOOLS", package:installdir())
    end)

    on_install("cross@windows", "cross@msys", function(package)
        os.cp("opt/devkitpro/tools/bin", package:installdir())
    end)

    on_test(function(package)
        assert(os.exists(package:installdir() .. "/bin/nacptool.exe"))
    end)
package_end()