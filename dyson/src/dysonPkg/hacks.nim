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
