package("bin2s")
    set_description("convert a binary file to a gcc asm module")
    set_homepage("https://github.com/Xtansia/bin2s")
    add_urls("https://github.com/HelloEngine/bin2s.git")

    on_install("@windows", "@msys", function(package)
        io.writefile("xmake.lua", [[
            target("bin2s")
                set_toolchains("mingw")
                set_kind("binary")
                on_install(function(target)
                    os.cp(target:targetfile() .. ".exe", target:installdir())
                end)
                add_cxxflags("-std=c++11", "-Wextra", "-Wpedantic", "-Werror")
                if is_mode("debug") then
                    add_cxxflags("-g")
                else
                    add_cxxflags("-O3", "-DNDEBUG")
                end

                add_files("src/bin2s.cpp")
                add_includedirs("deps/args")
        ]])

        import("package.tools.xmake").install(package, {})
    end)

    on_load(function(package)
        print("on_load:" .. package:name())
        package:addenv("PATH", package:installdir())
    end)

    on_test(function(package)
        assert(os.exists(package:installdir() .. "/bin2s.exe"))
    end)
        