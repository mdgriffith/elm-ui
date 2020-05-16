module Tests.Run exposing (main)

{-| _NOTE_ this is auto-generated!  Notouchy!
-}

import ElInFixedHeightColumn
import Testable.Runner


main : Testable.Runner.TestableProgram
main =
    Testable.Runner.program 
        [ Testable.Runner.rename " El In Fixed Height Column" ElInFixedHeightColumn.view
        ]
