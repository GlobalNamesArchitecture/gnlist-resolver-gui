module Terms.Encoder exposing (body)

import Json.Encode exposing (..)
import Http
import Data.Token as Token exposing (Token)


body : Token -> List String -> Http.Body
body token terms =
    Http.jsonBody <|
        object
            [ ( "token", Token.encode token )
            , ( "alt_headers", termsEncoder terms )
            ]


termsEncoder : List String -> Value
termsEncoder =
    list << List.map string
