package("bin2s")
    set_description("convert a binary file to a gcc asm module")
    set_homepage("https://github.com/Xtansia/bin2s")
    add_urls("https://github.com/HelloEngine/bin2s.git")

    on_install("@windows", "@msys", function(package)
        import("package.tools.xmake").install(package, {})
    end)

    on_load(function(package)
        package:addenv("PATH", package:installdir())
        --这里加一下mingw环境变量，免得依赖了bin2s不能直接在os.run里使用
        import("detect.sdks.find_mingw")
        local mingw = find_mingw()
        if mingw then
            package:addenv("PATH", mingw.bindir)
        end
    end)

    on_test(function(package)
        assert(os.exists(package:installdir() .. "/bin2s.exe"))
    end)
        