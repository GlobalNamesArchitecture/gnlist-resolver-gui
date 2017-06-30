module Resolver.Encoder exposing (body)

import Json.Encode exposing (..)
import Http


body : String -> Http.Body
body token =
    Http.jsonBody <|
        object
            [ ( "token", string token )
            , ( "stop_trigger", bool True )
            ]
