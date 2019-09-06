import cligen, os, osproc, parsecfg, rdstdin, strformat, strtabs, tempfile
import dysonPkg/[hacks]

include "dysonPkg/deployment_with_ingress.yaml"
include "dysonPkg/Dockerfile.slug"

type
  Config = object
    doToken: string
    cfEmail: string
    cfToken: string

proc toMap(conf: Config): StringTableRef =
  result = newStringTable()
  result["DIGITALOCEAN_TOKEN"] = conf.doToken
  result["TF_VAR_do_token"] = conf.doToken
  result["CLOUDFLARE_EMAIL"] = conf.cfEmail
  result["TF_VAR_cf_email"] = conf.cfEmail
  result["CLOUDFLARE_TOKEN"] = conf.cfToken
  result["TF_VAR_cf_token"] = conf.cfToken
  result["PATH"] = "PATH".getEnv
  result["HOME"] = "HOME".getEnv

proc load(fname: string): Config =
  var dict = parsecfg.loadConfig(fname)
  result.doToken = dict.getSectionValue("DigitalOcean", "Token")
  result.cfEmail = dict.getSectionValue("Cloudflare", "Email")
  result.cfToken = dict.getSectionValue("Cloudflare", "Token")

proc save(conf: Config, fname: string) =
  var dict = newConfig()
  dict.setSectionKey "DigitalOcean", "Token", conf.doToken
  dict.setSectionKey "Cloudflare", "Email", conf.cfEmail
  dict.setSectionKey "Cloudflare", "Token", conf.cfToken
  dict.writeConfig fname

proc confirm(msg: string, want: string) =
  var done = false
  while not done:
    echo msg
    let reply = readLineFromStdin("|reply: ")
    if reply == want:
      done = true
    else:
      echo fmt"wanted: {want}, got: {reply}"

proc runCommand(bin: string, args: openarray[string], env: StringTableRef) =
  let
    subp = startProcess(
      bin,
      args = args,
      env = env,
      options = {poParentStreams, poUsePath},
    )
    exitCode = subp.waitForExit()

  if exitCode != 0:
    echo fmt"unexpected exit code: {exitCode}"
    quit exitCode

const
  defConfigFname = "dyson.ini"
  defPlanFname = "tf.plan"

proc destroy(configFname = defConfigFname) =
  ## destroy resources managed by Terraform
  let cfg = configFname.load
  runCommand "terraform", ["destroy"], cfg.toMap

proc init(configFname = defConfigFname) =
  ## init Terraform
  let cfg = configFname.load
  runCommand "terraform", ["init"], cfg.toMap

proc plan(configFname = defConfigFname, planFname = defPlanFname) =
  ## plan a future Terraform run
  let cfg = configFname.load
  runCommand "terraform", ["plan", "-out=" & planFname], cfg.toMap

proc env(configFname = defConfigFname) =
  ## dump envvars
  let cfg = configFname.load
  for key, val in cfg.toMap.pairs:
    echo fmt"export {key}='{val}'"

proc apply(configFname = defConfigFname, planFname = defPlanFname) =
  ## apply Terraform code to production
  let cfg = configFname.load

  if not planFname.fileExists:
    plan(configFname, planFname)
    confirm(
        "Please stop and take a moment to scroll up and confirm this plan. Only 'yes' will be accepted.",
        "yes")
  defer: planFname.removeFile
  runCommand "terraform", ["apply", planFname], cfg.toMap

proc manifest(name, domain, dockerImage: string, containerPort, replicas: int, useProdLE: bool) =
  ## generate a somewhat sane manifest for a kubernetes app based on the arguments.
  echo genDeploymentWithIngress(name, domain, dockerImage, containerPort, replicas, useProdLE)

proc slug2docker(slugUrl: string, imageName: string) =
  ## converts a heroku/dokku slug to a docker image
  let dir = tempfile.mkdtemp()
  defer: removeDir(dir)
  withDir dir:
    assert execCmd(fmt"curl -o slug.tar.gz {slugUrl}") == 0
    writeFile "Dockerfile", genDockerfile("slug.tar.gz")
    assert execCmd(fmt"docker build -t {imageName} .") == 0
    assert execCmd(fmt"docker push {imageName}") == 0

when isMainModule:
  dispatchMulti [apply], [destroy], [env], [init], [manifest], [plan], [slug2docker]
