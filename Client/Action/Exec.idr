module Client.Action.Exec

import Client.Action.Build
import Fmt
import Inigo.Async.Base
import Inigo.Async.Package
import Inigo.Async.Promise
import Inigo.Package.CodeGen as CodeGen
import Inigo.Package.Package
import System.Path

execDir : String
execDir =
  "build/exec"

-- TODO: Better handling of base paths
export
exec : CodeGen -> Bool -> List String -> Promise ()
exec codeGen build userArgs =
  do
    pkg <- Client.Action.Build.writeIPkgFile
    if build then (runBuild codeGen pkg) else pure ()
    Just e <- lift $ executable pkg
      | Nothing => reject "No executable set in Inigo config"
    let (cmd, args) = CodeGen.cmdArgs codeGen (execDir </> e)
    log (fmt "Executing %s with args %s..." e (show userArgs))
    system cmd (args ++ userArgs) True True
    pure ()
