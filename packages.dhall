let upstream =
      https://github.com/purescript/package-sets/releases/download/psc-0.15.10-20230721/packages.dhall
        sha256:8800ac7d0763826544ca3ed3ba61f9dcef761a9e2a1feee0346437d9b861e78f

in  upstream
  with foreign-generic =
    { dependencies =
      [ "effect"
      , "foreign"
      , "foreign-object"
      , "exceptions"
      , "record"
      , "identity"
      ]
    , repo = "https://github.com/Adien7368/purescript-foreign-generic.git"
    , version = "master"
    }
  with codec-argonaut.version = "v9.0.0"
  with codec.version = "v5.0.0"
  with option =
    { dependencies =
      [ "aff"
      , "argonaut-codecs"
      , "argonaut-core"
      , "codec"
      , "codec-argonaut"
      , "datetime"
      , "effect"
      , "either"
      , "enums"
      , "foldable-traversable"
      , "foreign"
      , "foreign-object"
      , "identity"
      , "lists"
      , "maybe"
      , "prelude"
      , "profunctor"
      , "record"
      , "simple-json"
      , "spec"
      , "strings"
      , "transformers"
      , "tuples"
      , "unsafe-coerce"
      ]
    , repo = "https://github.com/thought2/purescript-option.git"
    , version = "upgrade-to-15"
    }
  with spec-mocha =
    { dependencies =
      [ "aff"
      , "datetime"
      , "effect"
      , "either"
      , "foldable-traversable"
      , "maybe"
      , "prelude"
      , "spec"
      ]
    , repo = "https://github.com/jmatsushita/purescript-spec-mocha.git"
    , version = "master"
    }
      