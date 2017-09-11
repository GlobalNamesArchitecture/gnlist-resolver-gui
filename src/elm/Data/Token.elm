module Data.Token
    exposing
        ( Token
        , toString
        , fromString
        , encode
        )

import Json.Encode


type Token
    = Token String


toString : Token -> String
toString (Token token) =
    token


fromString : String -> Token
fromString =
    Token


encode : Token -> Json.Encode.Value
encode =
    Json.Encode.string << toString
