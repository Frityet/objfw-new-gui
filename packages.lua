package("obj-ui")
    set_homepage("https://github.com/Frityet/ObjUI")
    add_urls("https://github.com/Frityet/ObjUI.git")

    on_install("macosx", function (package)
        import("package.tools.xmake").install(package)

        --add the lib dir to the rpath

        package:add("rpath", package:installdir("lib"))
        package:add("rpathdirs", package:installdir("lib"))
    end)
