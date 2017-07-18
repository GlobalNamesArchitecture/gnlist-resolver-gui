module Widgets.BreadCrumbs exposing (view)

import Html exposing (..)
import Material.Grid as Grid
import Material.Options as Options
import Material.Icon as Icon
import I18n exposing (Translation(..))
import Routing exposing (Route(..))
import Models exposing (Model)


view : Model -> Html msg
view model =
    Grid.grid [ Options.cs "breadcrumbs" ] <| List.concatMap (row model) stages


stages : List ( Int, String, String )
stages =
    [ ( 0, I18n.t BreadcrumbUploadFile, "file_upload" )
    , ( 1, I18n.t BreadcrumbMapHeaders, "map" )
    , ( 2, I18n.t BreadcrumbPickReferenceData, "wifi_tethering" )
    ]


step : Model -> Int
step model =
    case model.route of
        FileUpload ->
            0

        Terms _ ->
            1

        Target _ ->
            2

        Resolver _ ->
            3

        _ ->
            -1


type CellPosition
    = First
    | Middle
    | Last


type CrumbActivity
    = Active
    | Inactive
    | Completed


row : Model -> ( Int, String, String ) -> List (Grid.Cell msg)
row model ( pos, txt, icon ) =
    let
        icon_ =
            if step model <= pos then
                icon
            else
                "done"

        position =
            if pos == 0 then
                First
            else if pos + 1 == List.length stages then
                Last
            else
                Middle

        activity =
            if step model == pos then
                Active
            else if step model > pos then
                Completed
            else
                Inactive
    in
        viewCrumb position activity txt icon_


viewCrumb : CellPosition -> CrumbActivity -> String -> String -> List (Grid.Cell msg)
viewCrumb cellPosition crumbActivity txt icon =
    let
        additionalOptions =
            cellPositionOptions ++ activeOptions

        cellPositionOptions =
            case cellPosition of
                First ->
                    [ Grid.offset Grid.Desktop 2 ]

                _ ->
                    []

        activeOptions =
            case crumbActivity of
                Active ->
                    [ Options.cs "breadcrumbs__item-active" ]

                Completed ->
                    [ Options.cs "breadcrumbs__item-complete" ]

                _ ->
                    []

        additionalMarkup =
            case cellPosition of
                Last ->
                    []

                _ ->
                    [ arrowCrumb ]
    in
        [ Grid.cell ([ Options.cs "breadcrumbs__item", Grid.size Grid.Desktop 2, Grid.size Grid.Tablet 2 ] ++ additionalOptions) <|
            [ Options.div [ Options.cs "breadcrumbs__item-wrapper", Options.center ]
                [ Options.div [ Options.cs icon, Options.cs "breadcrumbs__item-icon" ] [ Icon.i icon ]
                , Options.div [ Options.cs "breadcrumbs__item-label" ] [ text txt ]
                ]
            ]
        ]
            ++ additionalMarkup


arrowCrumb : Grid.Cell a
arrowCrumb =
    Grid.cell
        [ Grid.size Grid.Desktop 1, Grid.size Grid.Tablet 1, Grid.size Grid.Phone 4, Grid.align Grid.Middle ]
        [ Options.span [ Options.cs "breadcrumbs__item-arrow", Options.center ] [ Icon.view "keyboard_arrow_right" [ Icon.size36 ] ] ]
