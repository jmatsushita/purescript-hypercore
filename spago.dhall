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
  , "enums"
  , "foldable-traversable"
  , "node-buffer"
  , "node-fs"
  , "option"
  , "prelude"
  , "spec"
  , "spec-mocha"
  , "strings"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
