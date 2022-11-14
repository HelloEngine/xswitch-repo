rule("switch.lib")
    on_config(function(target)
        assert(is_plat("cross"))
        assert(is_host("windows") or is_subhost("msys"))

        target:set("policy", "check.auto_ignore_flags", false)
        target:set("toolchains", "aarch64-none-elf@devkit-a64")
        target:set("kind", "static")

        local arch = {"-march=armv8-a", "-mtune=cortex-a57", "-mtp=soft", "-fPIE", "-ftls-model=local-exec", "-MMD", "-MP",
                    "-MF"}
        local cflags = {"-g", "-Wall", "-Werror", "-ffunction-sections", "-fdata-sections", table.unpack(arch)}
        local cxxflags = {"-fno-rtti", "-fno-exceptions", "-std=gnu++11", table.unpack(cflags)}
        local asflags = {"-g", table.unpack(arch)}

        target:add("cxxflags", table.unpack(cxxflags))
        target:add("cflags", table.unpack(cflags))
        target:add("asflags", table.unpack(asflags))
        target:add("defines", "__SWITCH__")

        if is_mode("debug") then
            target:add("cflags", "-DDEBUG=1", "-Og")
            target:add("cxxflags", "-DDEBUG=1", "-Og")
        else
            target:add("cflags", "-DDEBUG=1", "-O2")
            target:add("cxxflags", "-DDEBUG=1", "-O2")
        end
    end)
rule_end()

rule("switch.binary")
    on_config(function(target)
        -- flags
        target:set("policy", "check.auto_ignore_flags", false)
        target:set("kind", "binary")
        target:set("toolchains", "aarch64-none-elf@devkit-a64")

        local libnxPath = os.getenv("LIBNX")
        if not libnxPath then
            import("core.project.project")
            local libnx = project.required_package("libnx")
            if libnx then
                libnxPath = libnx:installdir()
            end
        end
        local specs = libnxPath .. "/xswitch.specs"
        local arch = {"-march=armv8-a+crc+crypto", "-mtune=cortex-a57", "-mtp=soft", "-fPIE"}
        local cflags = {"-g", "-Wall", "-O2", "-ffunction-sections", "-MMD", "-MP", "-MF", table.unpack(arch)}
        local cxxflags = {"-fno-rtti", "-fno-exceptions", "-MMD", "-MP", "-MF", table.unpack(cflags)}
        local asflags = {"-g", "-MMD", "-MP", "-MF", table.unpack(arch)}
        local ldflags =
            {"-specs=" .. specs, "-g", string.format("-Wl,-Map,build/%s.map", target:name()), table.unpack(arch)}
        target:add("cxxflags", table.unpack(cxxflags))
        target:add("cflags", table.unpack(cflags))
        target:add("asflags", table.unpack(asflags))
        target:add("ldflags", table.unpack(ldflags))
        target:add("defines", "__SWITCH__")
        if is_mode("debug") then
            target:add("cflags", "-DDEBUG=1", "-Og")
            target:add("cxxflags", "-DDEBUG=1", "-Og")
        else
            target:add("cflags", "-DDEBUG=1", "-O2")
            target:add("cxxflags", "-DDEBUG=1", "-O2")
        end
    end)
    on_link(function(target)
        import("core.tool.linker")
        import("core.project.config")
        print("on_link:" .. linker.linkcmd("binary", {"cc", "cxx", "as"}, target:objectfiles(), target:name() .. ".elf", {
            target = target
        }))
        local buildir = config.get("buildir")
        local outfile = string.format("%s/%s.elf", buildir, target:name())
        linker.link("binary", {"cc", "cxx", "as"}, target:objectfiles(), outfile, {
            target = target
        })
    end)

    after_link(function(target)
        -- -- Import task module
        -- import("core.project.task")
        -- -- Run the nro task
        -- task.run("nro")
        -- author [可选]作者名，默认为HelloGame，存储在nacp中
        -- version [可选]版本号，默认为1.0.0，存储在nacp中
        -- titleid [可选]应用标识符，存储在nacp中
        -- apptitle [可选]应用名，默认为target名，存储在nacp中
        -- icon [可选]图标，不传会用默认图标
        -- romfsdir [可选]romfs目录
        import("core.project.project")
        import("core.project.config")
        -- 参数
        local author = target:values("author") or "HelloGame"
        local version = target:values("version") or "1.0.0"
        local apptitle = target:values("apptitle") or target:name()
        local titleid = target:values("titleid") or false
        local default_icon = os.getenv("LIBNX") .. "/default_icon.jpg"
        local icon = target:values("icon") or default_icon
        local romfsdir = target:values("romfsdir") or false
        -- 标准方式只需要add_requires("switch-tools"),不需要去add_packages("switch-tools")
        local bin = os.getenv("SWITCH_TOOLS") .. "/bin"
        if not os.exists(bin .. "/nacptool.exe") then
            cprint("check switch-tools package...")
            local switchtools = project.required_package("switch-tools")
            if not switchtools then
                raise("please add add_requires(\"switch-tools\") to xmake.lua!")
            end

            bin = switchtools:installdir() .. "/bin"
        end
        os.addenv("PATH", bin)
        -- 生成nacp
        local buildir = config.get("buildir")
        local nacpfile = string.format("%s/%s.nacp", buildir, target:name())
        local nacpcmd = {"--create", apptitle, author, version, nacpfile}
        if titleid then
            nacpcmd[#nacpcmd + 1] = "--titleid=" .. titleid
        end
        os.execv("nacptool", nacpcmd)
        -- 检查nacp
        if not os.exists(nacpfile) then
            raise("failed to create .nacp file")
        end
        -- 生成nro
        local elffile = string.format("%s/%s.elf", buildir, target:name())
        -- 检查elf文件
        if not os.exists(elffile) then
            raise("can not find .elf file")
        end
        local nrofile = string.format("%s/%s.nro", buildir, target:name())
        local nrocmd = {elffile, nrofile, "--icon=" .. icon, "--nacp=" .. nacpfile}
        if romfsdir then
            nrocmd[#nrocmd + 1] = "--romfsdir=" .. romfsdir
        end
        os.execv("elf2nro", nrocmd)
        -- 检查nrofile
        if not os.exists(nrofile) then
            raise("failed to create .nro file")
        end
        cprint("build .nro success")
    end)
rule_end()
