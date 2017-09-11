module Resolver.Encoder exposing (body)

import Json.Encode exposing (..)
import Http
import Data.Token as Token exposing (Token)


body : Token -> Http.Body
body token =
    Http.jsonBody <|
        object
            [ ( "token", Token.encode token )
            , ( "stop_trigger", bool True )
            ]
