module Terms.Update exposing (update)

import Routing exposing (Route(Target, Resolver), navigateTo)
import Maybe exposing (withDefault)
import Http
import Helper as H
import Terms.Messages exposing (Msg(..))
import Terms.Models exposing (Terms, Term, Header)
import Terms.Decoder exposing (workflow, normalize)
import Terms.Encoder as TE


update : Msg -> Terms -> ( Terms, Cmd Msg )
update msg terms =
    case msg of
        MapTerm token id term ->
            let
                headers =
                    updateHeaders terms.headers id term

                termsList =
                    List.map (\h -> withDefault "" h.term) headers
            in
                ( { terms | headers = headers }, saveTerms token termsList )

        ToDataSources token ->
            ( terms, navigateTo <| Target token )

        ToResolver token ->
            ( terms, navigateTo <| Resolver token )

        GetTerms (Ok newTerms) ->
            ( newTerms, Cmd.none )

        GetTerms (Err _) ->
            ( terms, Cmd.none )

        SaveTerms (Ok _) ->
            let
                ( newWorkflowTerms, newHeaders ) =
                    determineWorkflow terms
            in
                ( { terms
                    | workflowTerms = newWorkflowTerms
                    , headers = newHeaders
                  }
                , Cmd.none
                )

        SaveTerms (Err _) ->
            ( terms, Cmd.none )


determineWorkflow : Terms -> ( List Term, List Header )
determineWorkflow terms =
    let
        normalizedHeaderTermValues =
            List.map
                (\h ->
                    normalize <|
                        withDefault "" h.term
                )
                terms.headers

        updatedTerms =
            workflow normalizedHeaderTermValues

        updatedHeaders =
            List.map (changeHeadersTerms updatedTerms) terms.headers
    in
        ( updatedTerms, updatedHeaders )


changeHeadersTerms : List Term -> Header -> Header
changeHeadersTerms terms header =
    let
        headerTerm =
            Maybe.withDefault "" header.term
    in
        if List.any (\t -> t.value == headerTerm) terms then
            header
        else
            Header header.id header.value Nothing


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
            "/list_matchers"
    in
        Http.send SaveTerms
            (H.put url <| TE.body token terms)
