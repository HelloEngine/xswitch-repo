rule("switch.lib")
    on_config(function(target)
        assert(is_plat("cross"))
        assert(is_host("windows") or is_subhost("msys"))

        target:set("policy", "check.auto_ignore_flags", false)
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
rule_end()
