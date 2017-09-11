module Terms.Helper exposing (getTerms)

import Http
import Terms.Messages exposing (Msg(..))
import Terms.Decoder exposing (termsDecoder)
import Data.Token as Token exposing (Token)


getTerms : Token -> Cmd Msg
getTerms token =
    let
        url =
            "/list_matchers/" ++ Token.toString token
    in
        Http.send GetTerms
            (Http.get url termsDecoder)
