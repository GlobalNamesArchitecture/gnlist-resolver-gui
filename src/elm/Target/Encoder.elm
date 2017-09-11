module Target.Encoder exposing (body)

import Json.Encode exposing (..)
import Http
import Data.Token as Token exposing (Token)


body : Token -> Int -> Http.Body
body token targetId =
    Http.jsonBody <|
        object
            [ ( "token", Token.encode token )
            , ( "data_source_id", int targetId )
            ]
