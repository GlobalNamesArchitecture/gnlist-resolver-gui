module Terms.Decoder exposing (termsDecoder, workflow, normalize, matchTerm)

import Maybe exposing (withDefault)
import Terms.Models
    exposing
        ( Terms
        , Term
        , Header
        , Row
        , sientificNameTerms
        , combinedTerms
        )
import Json.Decode exposing (..)


termsDecoder : Decoder Terms
termsDecoder =
    map4 Terms
        (at [ "output" ] string)
        headers
        workflowTerms
        rows


{-| Decide if to show full list of terms, or only ones that are related to the
`scientificName` workflow. List of headers has to be normalized.
-}
workflow : List String -> List Term
workflow normalizedHeaders =
    if List.any ((==) "scientificname") normalizedHeaders then
        sientificNameTerms
    else
        combinedTerms


{-| Normalize headers that are coming from user's data. Converts uri terms
into format recognizable by listresolver
-}
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


headers : Decoder (List Header)
headers =
    decodeHeaders |> andThen indexHeaders


decodeHeaders : Decoder (List String)
decodeHeaders =
    at [ "input_sample", "headers" ] <| list string


indexHeaders : List String -> Decoder (List Header)
indexHeaders headers =
    let
        workflowTerms =
            workflow <| List.map normalize headers
    in
        succeed <|
            List.indexedMap
                (\i h ->
                    Header (i + 1) h <|
                        matchTerm h workflowTerms
                )
                headers


workflowTerms : Decoder (List Term)
workflowTerms =
    decodeHeaders |> andThen (\l -> succeed <| workflowTermsHelper l)


workflowTermsHelper : List String -> List Term
workflowTermsHelper headers =
    workflow <| List.map normalize headers


matchTerm : String -> List Term -> Maybe String
matchTerm header workflowTerms =
    let
        rank =
            List.filter
                (\r -> normalize r == normalize header && r /= "")
            <|
                List.map .value workflowTerms
    in
        List.head rank


rows : Decoder (List Row)
rows =
    at [ "input_sample", "rows" ] <| list row


row : Decoder Row
row =
    list (nullable string)
