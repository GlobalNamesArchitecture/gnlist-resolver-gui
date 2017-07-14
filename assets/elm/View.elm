module View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Markdown
import Models exposing (Model)
import Messages exposing (Msg(..))
import Routing as R
import Errors exposing (Errors, Error)
import FileUpload.View as FUV
import Terms.View as TV
import Target.View as DSV
import Target.Helper as DSH
import Resolver.View as RV
import Widgets.BreadCrumbs as BC


view : Model -> Html Msg
view model =
    div []
        [ BC.view model
        , viewErrors model
        , findRoute model
        ]


findRoute : Model -> Html Msg
findRoute model =
    case model.route of
        R.FileUpload ->
            fileUploadView model

        R.Terms token ->
            termsView model token

        R.Target token ->
            dataSourceView model token

        R.Resolver _ ->
            resolverView model

        R.NotFoundRoute ->
            text "404 Not found"


fileUploadView : Model -> Html Msg
fileUploadView model =
    Html.map FileUploadMsg (FUV.view model.upload)


termsView : Model -> R.Token -> Html Msg
termsView model token =
    Html.map TermsMsg
        (TV.view model.target.all model.terms token)


dataSourceView : Model -> String -> Html Msg
dataSourceView model token =
    Html.map TargetMsg
        (DSV.view model.target token)


resolverView : Model -> Html Msg
resolverView model =
    Html.map ResolverMsg <|
        RV.view model.resolver
            (DSH.currentTarget model.target)
            model.terms


errors : Model -> Errors
errors model =
    let
        errors_ =
            List.filter (\l -> l /= Nothing)
                [ model.upload.errors, model.resolver.errors ]
    in
        if List.isEmpty errors_ then
            Nothing
        else
            errors_
                |> List.map (\l -> Maybe.withDefault [] l)
                |> List.concatMap identity
                |> Just


viewErrors : Model -> Html Msg
viewErrors model =
    case errors model of
        Nothing ->
            div [] [ text "No errors" ]

        Just es ->
            let
                errorList =
                    List.map viewError es ++ [ errorButton ]
            in
                div [ class "errors" ] errorList


viewError : Error -> Html Msg
viewError er =
    div [ class "error" ]
        [ h3 [] [ text er.title ]
        , Markdown.toHtml [] er.body
        ]


errorButton : Html Msg
errorButton =
    div [] [ button [ onClick EmptyErrors ] [ text "OK" ] ]
