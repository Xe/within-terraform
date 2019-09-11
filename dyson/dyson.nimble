# Package

version       = "0.1.0"
author        = "Christine Dodrill"
description   = "A simple wrapper for Terraform"
license       = "MIT"
srcDir        = "src"
binDir        = "bin"
bin           = @["dyson"]

# Dependencies

requires "nim >= 0.20.0", "cligen", "tempdir", "dotenv"

task package, "builds a tarball package":
  echo getCurrentDir()
  mode = ScriptMode.Verbose
  exec "nimble build"
  let folderName = "dyson-" & buildOS & "-" & buildCPU & "-" & version
  exec "rm -rf " & folderName
  defer: exec "rm -rf " & folderName
  mkDir folderName
  cpFile "../LICENSE", folderName & "/LICENSE"
  cpFile "./bin/dyson", folderName & "/dyson"
  exec "chmod 744 " & folderName & "/dyson"
  exec "tar czf " & folderName & ".tgz " & folderName

