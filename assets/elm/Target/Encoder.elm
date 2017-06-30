module Target.Encoder exposing (body)

import Json.Encode exposing (..)
import Http


body : String -> Int -> Http.Body
body token targetId =
    Http.jsonBody <|
        object
            [ ( "token", string token )
            , ( "data_source_id", int targetId )
            ]
