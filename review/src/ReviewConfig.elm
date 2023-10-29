module ReviewConfig exposing (config)

{-| Do not rename the ReviewConfig module or the config function, because
`elm-review` will look for these.

To add packages that contain rules, add them to this review project using

    `elm install author/packagename`

when inside the directory containing this file.

-}

import Docs.NoMissing exposing (exposedModules, onlyExposed)
import Docs.ReviewAtDocs
import Docs.ReviewLinksAndSections
import Docs.UpToDateReadmeLinks
import NoConfusingPrefixOperator
import NoDebug.Log
import NoDebug.TodoOrToString
import NoExposingEverything
import NoImportingEverything
import NoMissingTypeAnnotation
import NoMissingTypeAnnotationInLetIn
import NoMissingTypeExpose
import NoPrematureLetComputation
import NoSimpleLetBody
import NoUnused.CustomTypeConstructorArgs
import NoUnused.CustomTypeConstructors
import NoUnused.Dependencies
import NoUnused.Exports
import NoUnused.Parameters
import NoUnused.Patterns
import NoUnused.Variables
import Review.Rule as Rule exposing (Rule)
import Simplify


config : List Rule
config =
    List.map
        (Rule.ignoreErrorsForDirectories [ "tests/" ])
        [ -- Docs.NoMissing.rule
          -- { document = onlyExposed
          -- , from = exposedModules
          -- }
          -- ,
          Docs.ReviewLinksAndSections.rule
        , Docs.ReviewAtDocs.rule
        , Docs.UpToDateReadmeLinks.rule
        , NoConfusingPrefixOperator.rule
        , NoDebug.Log.rule
        , NoDebug.TodoOrToString.rule
            |> Rule.ignoreErrorsForDirectories [ "tests/" ]
        , NoExposingEverything.rule
        , NoImportingEverything.rule []
        , NoMissingTypeAnnotation.rule
        , NoMissingTypeExpose.rule
        , NoSimpleLetBody.rule
        , NoPrematureLetComputation.rule
        , NoUnused.CustomTypeConstructors.rule []
        , NoUnused.CustomTypeConstructorArgs.rule
        , NoUnused.Dependencies.rule
        , NoUnused.Exports.rule
        , NoUnused.Parameters.rule
        , NoUnused.Patterns.rule
        , NoUnused.Variables.rule
        , Simplify.rule Simplify.defaults
        ]
