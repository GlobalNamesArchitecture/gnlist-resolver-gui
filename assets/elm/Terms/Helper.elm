module Terms.Helper exposing (getTerms)

import Http
import Terms.Messages exposing (Msg(..))
import Terms.Decoder exposing (termsDecoder)


getTerms : String -> Cmd Msg
getTerms token =
    let
        url =
            "/list_matchers/" ++ token
    in
        Http.send GetTerms
            (Http.get url termsDecoder)
