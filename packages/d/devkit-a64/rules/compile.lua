
rule("compile.flags")
on_config(function(target)
    assert(is_plat("cross"))
    assert(is_host("windows") or is_subhost("msys"))

    target:set("policy", "check.auto_ignore_flags", false)
    
    local arch, cflags, cxxflags, asflags, ldflags
    if target:get("kind") == "static" then
        arch = {
            "-march=armv8-a", 
            "-mtune=cortex-a57", 
            "-mtp=soft", 
            "-fPIC", 
            "-ftls-model=local-exec",
            "-MMD", 
            "-MP",
            "-MF"
        }
        cflags = {
            "-g", 
            "-Wall", 
            "-Werror", 
            "-ffunction-sections", 
            "-fdata-sections", 
            table.unpack(arch)
        }
        cxxflags = {
            "-fno-rtti", 
            "-fno-exceptions", 
            "-std=gnu++11", 
            table.unpack(cflags)
        }
        asflags = {
            "-g", 
            table.unpack(arch)
        }
    elseif target:get("kind") ==  "binary" then
        arch = {
            "-march=armv8-a+crc+crypto", 
            "-mtune=cortex-a57", 
            "-mtp=soft", 
            "-fPIE"
        }
        cflags = {
            "-g", 
            "-Wall", 
            "-O2", 
            "-ffunction-sections", 
            "-MMD", 
            "-MP", 
            "-MF", 
            table.unpack(arch)
        }
        cxxflags = {
            "-fno-rtti", 
            "-fno-exceptions", 
            "-MMD", 
            "-MP", 
            "-MF", 
            table.unpack(cflags)
        }
        asflags = {
            "-g", 
            "-MMD", 
            "-MP", 
            "-MF", 
            table.unpack(arch)
        }
        ldflags = {
            "-g", 
            string.format("-Wl,-Map,build/%s.map", target:name()), 
            table.unpack(arch)
        }
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

    local devkita64path = os.getenv("DEVKITA64")
    if not devkita64path then
        cprint("check switch-tools package...")
        local package = project.required_package("devkit-a64")
        if not package then
            raise("please add add_requires(\"devkit-a64\") to xmake.lua!")
        end

        devkita64path = package:installdir()
    end

    target:add("includedirs", devkita64path .. "/aarch64-none-elf/include")
    target:add("linkdirs", devkita64path .. "/aarch64-none-elf/lib")
end)