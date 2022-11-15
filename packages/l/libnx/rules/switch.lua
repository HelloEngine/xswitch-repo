rule("switch.nro")
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