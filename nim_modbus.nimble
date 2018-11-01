# Package

version       = "0.1.0"
author        = "Takeyoshi Kikuchi"
description   = "libmodbus binding for Nim"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["examples"]

task build_arm, "Build for ARM":
  exec "nim c --cpu:arm -d:release examples/modbus_example"

# Dependencies
requires "nim >= 0.19.0"
