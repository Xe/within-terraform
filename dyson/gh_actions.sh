#!/bin/sh

echo '[DigitalOcean]
Token = ""

[Cloudflare]
Email = ""
Token = ""

[Secrets]
GitCheckout = "/github/workspace/within-terraform-secret"' > $HOME/.config/dyson/dyson.ini

dyson $*
