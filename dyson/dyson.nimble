# Package

version       = "0.1.0"
author        = "Christine Dodrill"
description   = "A simple wrapper for Terraform"
license       = "MIT"
srcDir        = "src"
bin           = @["dyson"]



# Dependencies

requires "nim >= 0.20.0", "cligen", "tempfile"
