import os, streams, dotenv, dotenv/private/envparser

proc concat*[I1, I2: static[int]; T](a: array[I1, T], b: array[I2, T]): array[I1 + I2, T] =
  result[0..a.high] = a
  result[a.len..result.high] = b

template withDir*(dir: string; body: untyped): untyped =
  ## Changes the current directory temporarily.
  ##
  ## If you need a permanent change, use the `cd() <#cd>`_ proc. Usage example:
  ##
  ## .. code-block:: nim
  ##   withDir "foo":
  ##     # inside foo
  ##   #back to last dir
  var curDir = getCurrentDir()
  try:
    setCurrentDir(dir)
    body
  finally:
    setCurrentDir(curDir)

type Envvar* = tuple[name: string, value: string]

iterator loadFromStream(s: Stream, filePath: string = ""): EnvVar {.raises: [DotEnvParseError, ref ValueError, Exception].} =
  ## Read all of the environment variables from the given stream.
  var parser: EnvParser
  envparser.open(parser, s, filePath)
  defer: close(parser)
  while true:
    var e = parser.next()
    case e.kind
    of EnvEventKind.Eof:
      break
    of EnvEventKind.KeyValuePair:
      yield (name: e.key, value: e.value)
    of EnvEventKind.Error:
      raise newException(DotEnvParseError, e.msg)

iterator loadFromFile*(filePath: string): EnvVar {.tags: [ReadDirEffect, ReadIOEffect, RootEffect], raises: [DotEnvReadError, DotEnvParseError, ref ValueError, Exception].} =
  ## Load the environment variables from a file at the given `filePath`.
  let f = newFileStream(filePath, fmRead)

  if isNil(f):
    raise newException(DotEnvReadError, "Failed to read env file")

  for entry in loadFromStream(f, filePath):
    yield entry


