module Terms.Encoder exposing (body)

import Json.Encode exposing (..)
import Http


body : String -> List String -> Http.Body
body token terms =
    Http.jsonBody <|
        object
            [ ( "token", string token )
            , ( "alt_headers", termsEncoder terms )
            ]


termsEncoder : List String -> Value
termsEncoder terms =
    list <| List.map (\t -> string t) terms
