rule("switch")
    on_config(function(target)
        target:set("policy", "check.auto_ignore_flags", false)

        import("core.project.project")
        local specs = project.required_package("libnx"):installdir() .. "/switch.specs"

        local arch = {
            "-march=armv8-a+crc+crypto", 
            "-mtune=cortex-a57", 
            "-mtp=soft", 
            "-fPIE"
        }
        local cflags = {
            "-g", 
            "-Wall", 
            "-O2",
            "-ffunction-sections",
            "-MMD", "-MP", "-MF",
            table.unpack(arch)
        }
        local cxxflags = {
            "-fno-rtti",
            "-fno-exceptions", 
            table.unpack(cflags)
        }
        local asflags = {
            "-g", 
            table.unpack(arch)
        }
        local ldflags = {
            "-specs=" .. specs, 
            "-g",
            string.format("-Wl,-Map,build/%s.map", target:name()),
            table.unpack(arch),
        }

        target:add("cxxflags", table.unpack(cxxflags))
        target:add("cflags", table.unpack(cflags))
        target:add("asflags", table.unpack(asflags))
        target:add("ldflags", table.unpack(ldflags))
        target:add("defines", "__SWITCH__")
    end)

    on_link(function(target)
        import("core.tool.linker")
        print("on_link:" .. linker.linkcmd("binary", {"cc", "cxx", "as"}, target:objectfiles(), "build/" .. target:name()..".elf", {target = target}))
        linker.link("binary", {"cc", "cxx", "as"}, target:objectfiles(), "build/" .. target:name()..".elf", {target = target})
    end)
rule_end()