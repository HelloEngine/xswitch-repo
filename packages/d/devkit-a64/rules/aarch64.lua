rule("aarch64")
    on_config(function(target)
        assert(is_plat("cross"))
        assert(is_host("windows") or is_subhost("msys"))

        target:set("policy", "check.auto_ignore_flags", false)

        local arch, cflags, cxxflags, asflags, ldflags
        if target:get("kind") == "static" then
            arch = {"-march=armv8-a+crc+crypto", "-mtune=cortex-a57", "-mtp=soft", "-fPIC", "-ftls-model=local-exec",
                    "-MMD", "-MP", "-MF"}
            cflags = {"-g", "-Wall", "-Werror", "-ffunction-sections", "-fdata-sections", table.unpack(arch)}
            cxxflags = {"-fno-rtti", "-fno-exceptions", table.unpack(cflags)}
            asflags = {"-g", table.unpack(arch)}
        elseif target:get("kind") == "binary" then
            arch = {"-march=armv8-a+crc+crypto", "-mtune=cortex-a57", "-mtp=soft", "-fPIE"}
            cflags = {"-g", "-Wall", "-O2", "-ffunction-sections", "-MMD", "-MP", "-MF", table.unpack(arch)}
            cxxflags = {"-fno-rtti", "-fno-exceptions", "-MMD", "-MP", "-MF", table.unpack(cflags)}
            asflags = {"-g", "-MMD", "-MP", "-MF", table.unpack(arch)}
            ldflags = {"-g", string.format("-Wl,-Map,build/%s.map", target:name()), table.unpack(arch)}
        else
            raise("unsopported target kind")
        end

        target:add("cxxflags", table.unpack(cxxflags))
        target:add("cflags", table.unpack(cflags))
        target:add("asflags", table.unpack(asflags))
        if ldflags then
            target:add("ldflags", table.unpack(ldflags))
        end
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

        local envs = {}
        local tenvs = target:values("envs")
        if tenvs then
            for i = 1, #tenvs, 2 do
                os.addenv(tenvs[i], tenvs[i + 1])
            end
        end

        if target:get("kind") == "static" then
            print(linker.linkcmd("static", {"cc", "cxx", "as"}, target:objectfiles(), target:targetfile(), {
                target = target
            }))
            linker.link("static", {"cc", "cxx", "as"}, target:objectfiles(), target:targetfile(), {
                target = target
            })
        elseif target:get("kind") == "binary" then
            local buildir = config.get("buildir")
            local outfile = string.format("%s\\%s.elf", buildir, target:name())

            print(linker.linkcmd("binary", {"cc", "cxx", "as"}, target:objectfiles(), outfile, {
                target = target
            }))
            linker.link("binary", {"cc", "cxx", "as"}, target:objectfiles(), outfile, {
                target = target
            })
            -- os.mkdir(path.directory(outfile))
            -- os.runv(linker.linkargv("binary", {"cc", "cxx", "as"}, target:objectfiles(), outfile, {
            --     target = target
            -- })})
        end
    end)
rule_end()
