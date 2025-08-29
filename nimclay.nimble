when defined(nimsuggest):
  import system/nimscript

version       = "0.1.1"
author        = "Nimaoth/thearchivalone"
description   = "Nim wrapper for clay"
license       = "MIT"
srcDir        = "src"

requires "nim >= 2.0.8"

const path_delimiter = when defined(Windows): "\\" else: "/"
const nim_deps = when existsEnv("NIMDEPS"): getEnv("NIMDEPS") else: nimcacheDir()

const clay_dir = nim_deps & path_delimiter & "nimclay.thearchivalone.github.com"
const clay_src_dir = clay_dir & path_delimiter & "src" & path_delimiter & "clay"

task dep, "":
  if not dirExists(clay_src_dir):
    exec("git clone" & " " &
        "--recursive" & " " &
        "--depth=1" & " " &
        "https://github.com/nicbarker/clay.git" &
        " " &
        clay_src_dir)

before install:
  depTask()
