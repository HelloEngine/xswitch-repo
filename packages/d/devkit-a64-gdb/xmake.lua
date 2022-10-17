local versionUrls = {
    ["1.0.0"] = "devkitA64-gdb-11.2-1-windows_x86_64.pkg.tar.xz"
}

package("devkit-a64-gdb")
    add_versions("1.0.0", "e175365b760f3360b612400da4488ebd779b2b8e8c35f4a2163d2e66222cff08")
    set_description("Nintendo Switch aarch64-none-elf gdb")
    set_homepage("https://github.com/devkitPro")
    add_urls("https://wii.leseratte10.de/devkitPro/devkitA64/devkitA64-gdb/$(version)", {version = function(version)
        return versionUrls[version:shortstr()]
    end})

    on_load(function(package)
        package:addenv("DEVKITA64_GDB", package:installdir())
    end)

    on_install("cross@msys","cross@windows", function(package)
        os.cp("opt/devkitpro/devkitA64/bin", package:installdir())
        os.cp("opt/devkitpro/devkitA64/include", package:installdir())
        os.cp("opt/devkitpro/devkitA64/lib", package:installdir())
        os.cp("opt/devkitpro/devkitA64/share", package:installdir())
    end)

    on_test(function(package)
        assert(os.exists(package:installdir() .. "/bin/aarch64-none-elf-gdb.exe"))
    end)
package_end()