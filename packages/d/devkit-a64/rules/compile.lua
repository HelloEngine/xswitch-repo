local cc = ""
local cxx = ""
local as = ""
local ar = ""
local havecxxfile = false
local devkita64Path = ""

local function getlanguange(file)
    local extension = path.extension(file)
    if extension == ".cpp" or extension == ".cpp" or extension == ".hpp" or extension == ".cc" or extension == ".cxx" then
        return "cxx"
    elseif extension == ".c" then
        return "c"
    elseif extension == ".s" or extension == ".S" then
        return "as"
    end
end

rule("compile")
    set_extensions(".c", ".cpp", ".s", ".S", ".hpp", ".cc", ".cxx")

    on_config(function(target)
        devkita64Path = os.getenv("DEVKITA64")
        if not devkita64Path then
            cprint("check switch-tools package...")
            local package = project.required_package("devkit-a64")
            if not package then
                raise("please add add_requires(\"devkit-a64\") to xmake.lua!")
            end

            devkita64Path = package:installdir()
        end
        cc = devkita64Path .. "/bin/aarch64-none-elf-gcc"
        cxx = devkita64Path .. "/bin/aarch64-none-elf-g++"
        as = devkita64Path .. "/bin/aarch64-none-elf-as"
        ar = devkita64Path .. "/bin/aarch64-none-elf-ar"
    end)

    on_buildcmd_file(function(target, batchcmds, sourcefile, opt)
        local language = getlanguange(sourcefile)
        if not language then
            raise("unsopport file " .. sourcefile)
        end

        if not havecxxfile and language == "cxx" then
            havecxxfile = true
        end

        -- compiler
        local compiler = cc
        if language == "cxx" then
            compiler = cxx
        elseif language == "as" then
            compiler = as
        end

        -- dep
        local depdir = target:dependir()
        if not os.exists(depdir) then
            os.mkdir(depdir)
        end
        local depfile = path.join(depdir, path.basename(sourcefile) .. ".d")

        local args = {"-MMD", "-MP", "-MF", depfile, "-march=armv8-a+crc+crypto", "-mtune=cortex-a57", "-mtp=soft"}
        -- flags
        if target:get("kind") == "binary" then
            table.insert(args, "-fPIE")

            if language == "cxx" or language == "c" then
                table.insert(args, "-g")
                table.insert(args, "-Wall")
                table.insert(args, "-O2")
                table.insert(args, "-ffunction-sections")
            elseif language == "as" then
                table.insert(args, 5, "-x")
                table.insert(args, 6, "assembler-with-cpp")
                table.insert(args, 7, "-g")
            end

        elseif target:get("kind") == "static" then
            table.insert(args, "-fPIC")
            table.insert(args, "-ftls-model=local-exec")

            if language == "cxx" or language == "c" then
                table.insert(args, "-g")
                table.insert(args, "-Wall")
                table.insert(args, "-Werror")
                table.insert(args, "-ffunction-sections")
                table.insert(args, "-fdata-sections")

                if is_mode("release") then
                    table.insert(args, "-DNDEBUG=1")
                    table.insert(args, "-O2")
                else
                    table.insert(args, "-DNDEBUG=1")
                    table.insert(args, "-O2")
                end
            elseif language == "as" then
                table.insert(args, 5, "-x")
                table.insert(args, 6, "assembler-with-cpp")
                table.insert(args, 7, "-g")
            end
        end

        -- cxxflags
        if language == "cxx" then
            table.insert(args, "-fno-rtti")
            table.insert(args, "-fno-exceptions")
        end

        local flags = false
        if language == "cxx" then
            flags = target:get("cxxflags")
        elseif language == "c" then
            flags = target:get("cflags")
        elseif language == "as" then
            flags = target:get("asflags")
        end
        if flags then
            for i, v in ipairs(flags) do
                table.insert(args, v)
            end
        end

        if language == "cxx" or language == "c" then
            local packages = target:pkgs()

            -- includedirs
            local includedirs = target:get("includedirs")
            if includedirs then
                for i, v in ipairs(includedirs) do
                    table.insert(args, "-I" .. v)
                end
            end
            if packages then
                for _, package in pairs(packages) do
                    local includedirs = package:get("sysincludedirs")
                    if not includedirs then
                        includedirs = package:get("includedirs")
                    end
                    if includedirs then
                        for i, v in ipairs(includedirs) do
                            table.insert(args, "-I" .. v)
                        end
                    end
                end
            end

            -- defines
            table.insert(args, "-D__SWITCH__")
            local defines = target:get("defines")
            if defines then
                for i, v in ipairs(defines) do
                    table.insert(args, "-D" .. v)
                end
            end
        end

        table.insert(args, "-c")
        table.insert(args, sourcefile)
        table.insert(args, "-o")
        local objdir = target:objectdir()
        if not os.exists(objdir) then
            os.mkdir(objdir)
        end
        local outfile = path.join(objdir, path.basename(sourcefile) .. ".o")
        target:add("values", "objectfiles", outfile)
        table.insert(args, outfile)

        -- .o
        batchcmds:show_progress(opt.progress, "${color.build.object}compiling.$(mode) %s", sourcefile)
        batchcmds:vrunv(compiler, args)
    end)

    on_link(function(target)
        if target:get("kind") == "binary" then
            local packages = target:pkgs()

            local ld = cc
            if havecxxfile then
                ld = cxx
            end
            ld = path.translate(ld)

            local args = {"-g", "-march=armv8-a+crc+crypto", "-mtune=cortex-a57", "-mtp=soft", "-fPIE"}

            -- map
            import("core.project.config")
            local buildir = config.get("buildir")
            table.insert(args, format("-Wl,-Map,%s.map", path.join(buildir, target:name())))

            -- flags
            local flags = target:get("ldflags")
            if flags then
                for i, v in ipairs(flags) do
                    table.insert(args, v)
                end
            end

            -- .o
            local objfiles = target:values("objectfiles")
            for i, v in ipairs(objfiles) do
                table.insert(args, v)
            end

            -- linkdirs
            local linkdirs = target:get("linkdirs")
            if linkdirs then
                for i, v in ipairs(linkdirs) do
                    table.insert(args, "-L" .. path.translate(v))
                end
            end
            if packages then
                for _, package in pairs(packages) do
                    local linkdirs = package:get("linkdirs")
                    if linkdirs then
                        for i, v in ipairs(linkdirs) do
                            table.insert(args, "-L" .. v)
                        end
                    end
                end
            end

            -- links
            local links = target:get("links")
            if links then
                for i, v in ipairs(links) do
                    table.insert(args, "-l" .. v)
                end
            end
            if packages then
                for _, package in pairs(packages) do
                    local links = package:get("links")
                    if links then
                        for i, v in ipairs(links) do
                            table.insert(args, "-l" .. v)
                        end
                    end
                end
            end

            -- .elf
            local outfile = string.format("%s/%s.elf", buildir, target:name())
            outfile = path.translate(outfile)
            -- outfile = path.absolute(outfile, target:scriptdir())
            table.insert(args, "-o")
            table.insert(args, outfile)

            cprint("${color.build.target}linking.$(mode) %s", target:name())
            cprint(ld .. " " .. table.concat(args, " "))

            local envs = {}
            local tenvs = target:values("envs")
            if tenvs then
                for i = 1, #tenvs, 2 do
                    envs[tenvs[i]] = tenvs[i + 1]
                end
            end
            os.mkdir(path.directory(outfile))
            os.runv(ld, args, {
                envs = envs
            })

        elseif target:get("kind") == "static" then
            local targetdir = target:targetdir()
            if not os.exists(targetdir) then
                os.mkdir(targetdir)
            end

            local outfile = path.join(targetdir, target:name() .. ".a")

            -- ar
            local args = {"-rc", outfile}

            -- flags
            local flags = target:get("arflags")
            if flags then
                for i, v in ipairs(flags) do
                    table.insert(args, v)
                end
            end

            -- .o
            local objfiles = target:values("objectfiles")
            for i, v in ipairs(objfiles) do
                table.insert(args, v)
            end

            cprint("${color.build.target}ar.$(mode) %s", target:name())
            cprint(ar .. " " .. table.concat(args, " "))

            local envs = {}
            local tenvs = target:values("envs")
            if tenvs then
                for i = 1, #tenvs, 2 do
                    envs[tenvs[i]] = tenvs[i + 1]
                end
            end
            os.mkdir(path.directory(outfile))
            os.runv(ar, args, {
                envs = envs
            })
        end
    end)
