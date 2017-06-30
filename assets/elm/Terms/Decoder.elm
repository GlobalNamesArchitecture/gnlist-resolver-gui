module Terms.Decoder exposing (termsDecoder)

import Result
import Maybe exposing (withDefault)
import Terms.Models
    exposing
        ( Terms
        , Header
        , Row
        , allFields
        )
import Json.Decode exposing (..)


termsDecoder : Decoder Terms
termsDecoder =
    map3 Terms
        (at [ "output" ] string)
        headers
        rows



-- PRIVATE


headers : Decoder (List Header)
headers =
    let
        hDecoder =
            at [ "input_sample", "headers" ] <| list string
    in
        hDecoder |> andThen indexHeaders


indexHeaders : List String -> Decoder (List Header)
indexHeaders headers =
    succeed <| List.indexedMap (\i h -> Header (i + 1) h <| matchTerm h) headers


matchTerm : String -> Maybe String
matchTerm header =
    let
        rank =
            List.filter
                (\r -> (normalize r) == (normalize header) && r /= "")
                allFields
    in
        List.head rank


normalize : String -> String
normalize word =
    word
        |> String.split ":"
        |> List.reverse
        |> List.head
        |> withDefault ""
        |> String.split "/"
        |> List.reverse
        |> List.head
        |> withDefault ""
        |> String.toLower


rows : Decoder (List Row)
rows =
    at [ "input_sample", "rows" ] <| list row


row : Decoder Row
row =
    list (nullable string)
