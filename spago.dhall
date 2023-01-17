{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "hypercore"
, dependencies =
  [ "aff"
  , "aff-promise"
  , "console"
  , "effect"
  , "node-buffer"
  , "node-fs"
  , "option"
  , "prelude"
  , "spec"
  , "spec-mocha"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
