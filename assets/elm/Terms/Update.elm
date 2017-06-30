module Terms.Update exposing (update)

import Navigation exposing (newUrl)
import Maybe exposing (withDefault)
import Http
import Helper as H
import Terms.Messages exposing (Msg(..))
import Terms.Models exposing (Terms, Header)
import Terms.Encoder as TE


update : Msg -> Terms -> ( Terms, Cmd Msg )
update msg terms =
    case msg of
        MapTerm token id term ->
            let
                headers =
                    updateHeaders terms.headers id term

                termsList =
                    List.map (\h -> withDefault h.value h.term) headers
            in
                ( { terms | headers = headers }, saveTerms token termsList )

        ToDataSources token ->
            ( terms, newUrl <| "/#target/" ++ token )

        ToResolver token ->
            ( terms, newUrl <| "/#resolver/" ++ token )

        GetTerms (Ok newTerms) ->
            ( newTerms, Cmd.none )

        GetTerms (Err err) ->
            ( terms, Cmd.none )

        SaveTerms (Ok _) ->
            ( terms, Cmd.none )

        SaveTerms (Err _) ->
            ( terms, Cmd.none )


updateHeaders : List Header -> Int -> String -> List Header
updateHeaders headers id term =
    List.map
        (\h ->
            if h.id == id then
                Header h.id h.value <| prepareTerm term
            else
                h
        )
        headers


prepareTerm : String -> Maybe String
prepareTerm term =
    if String.isEmpty term then
        Nothing
    else
        Just term


saveTerms : String -> List String -> Cmd Msg
saveTerms token terms =
    let
        url =
            "/crossmaps"
    in
        Http.send SaveTerms
            (H.put url <| TE.body token terms)
