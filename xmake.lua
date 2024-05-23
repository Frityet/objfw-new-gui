---@diagnostic disable: undefined-global

includes("packages.lua")

--Sanitizers to use when building in debug mode
local sanitizers = { "address", "leak", "undefined" }

--Objective C compilation flags
local mflags = {
    release = {},
    debug = {
        "-Wno-unused-function", "-Wno-unused-parameter", "-Wno-unused-variable"
    },
    regular = {
        "-Wall", "-Wextra", "-Werror",
    }
}

--Objective C linker flags
local ldflags = {
    release = {
        "-flto"
    },
    debug = {},
    regular = {}
}

--C standard to use, `gnulatest` means the latest C standard + GNU extensions
set_languages("gnulatest")

add_requires("objfw", { configs = { shared = is_kind("shared") } })
add_requires("obj-ui master", "libui master", { configs = { shared = is_kind("shared") } })

target("ObjFW-New-GUI")
do
    set_kind("binary")
    add_packages("objfw")
    add_packages("obj-ui", "libui")

    add_files("src/**.m")
    add_headerfiles("src/**.h")
    add_includedirs("src")

    add_mflags(mflags.regular)
    add_ldflags(ldflags.regular)

    if is_mode("debug", "check") then
        add_mflags(mflags.debug)
        add_ldflags(ldflags.debug)

        add_defines("PROJECT_DEBUG")
        if is_mode("check") then
            cprint("${yellow}WARNING: Sanitizers make ObjFW run extremely slow")
            for _, v in ipairs(sanitizers) do
                add_mflags("-fsanitize=" .. v)
                add_ldflags("-fsanitize=" .. v)
            end
        end
    elseif is_mode("release", "minsizerel") then
        add_mflags(mflags.release)
        add_ldflags(ldflags.release)
        if is_mode("minsizerel") then
            set_symbols("hidden")
            set_optimize("smallest")
            set_strip("all")
        end
    end
end
target_end()
