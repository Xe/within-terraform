#!/bin/sh

mkdir -p $HOME/.config/dyson
echo '[DigitalOcean]
Token = ""

[Cloudflare]
Email = ""
Token = ""

[Secrets]
GitCheckout = "/github/workspace/within-terraform-secret"' > $HOME/.config/dyson/dyson.ini

set -e
set -x
exec dyson $*
