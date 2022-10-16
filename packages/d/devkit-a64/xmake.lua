local versionUrls = {
    ["1.0.0"] = "r19%20%282022-05-30%29/devkitA64-r19-2-windows_x86_64.pkg.tar.xz"
}

package("devkit-a64")
    set_kind("toolchains")
    add_versions("1.0.0", "cbebe417785f186c6cc8a7d207a706d80080953f1f52bdb0ff60ce51739765cf")
    set_description("Nintendo Switch aarch64-none-elf toolchain")
    set_homepage("https://github.com/devkitPro")
    if is_plat("mingw") and is_arch("x86_64") then
        add_urls("https://wii.leseratte10.de/devkitPro/devkitA64/$(version)", {version = function(version)
            return versionUrls[version:shortstr()]
        end})
    end

    on_load(function(package)
        package:addenv("DEVKITA64", package:installdir())
    end)

    on_install("mingw|x86_64", function(package)
        os.cp("opt/devkitpro/devkitA64/aarch64-none-elf", package:installdir())
        os.cp("opt/devkitpro/devkitA64/bin", package:installdir())
        os.cp("opt/devkitpro/devkitA64/include", package:installdir())
        os.cp("opt/devkitpro/devkitA64/lib", package:installdir())
        os.cp("opt/devkitpro/devkitA64/libexec", package:installdir())
        os.cp("opt/devkitpro/devkitA64/share", package:installdir())
    end)

    on_test(function(package)
        assert(os.exists(package:installdir() .. "/bin/aarch64-none-elf-c++.exe"))
    end)
package_end()