module Widgets.Pie exposing (pie, PieData, PieDatum)

{-| An SVG chart library.


# Pie

@docs pie
@docs PieData

-}

import List
import Svg
import Html exposing (..)
import Html.Attributes as HA
import Svg.Attributes


type alias PieData =
    List PieDatum


type alias PieDatum =
    { color : String
    , value : Float
    , legend : String
    }


type alias ArcOutput =
    { id : Int
    , x1 : Float
    , y1 : Float
    , x2 : Float
    , y2 : Float
    , largeArcFlag : Int
    , color : String
    }


half : Float
half =
    pi


round : Float
round =
    pi * 2


radius : Float
radius =
    0.5


getPointX : Float -> Float
getPointX angle =
    radius * cos angle


getPointY : Float -> Float
getPointY angle =
    radius * sin angle


getTotalOfPieData : PieData -> Float
getTotalOfPieData dataset =
    List.sum (List.map .value dataset)


getArc : { dataset : PieData, datum : PieDatum, index : Int, total : Float } -> ArcOutput
getArc { dataset, datum, index, total } =
    let
        drawnValue =
            getTotalOfPieData (List.take index dataset)

        startAngle =
            round * drawnValue / total

        angle =
            round * datum.value / total

        endAngle =
            startAngle + angle
    in
        { id = index
        , x1 = getPointX startAngle
        , y1 = getPointY startAngle
        , x2 = getPointX endAngle
        , y2 = getPointY endAngle
        , largeArcFlag =
            if angle > half then
                1
            else
                0
        , color = datum.color
        }


arcToPath : ArcOutput -> String
arcToPath { x1, y1, x2, y2, largeArcFlag } =
    "M0,0 L"
        ++ toString x1
        ++ ","
        ++ toString y1
        ++ " A0.5,0.5 0 "
        ++ toString largeArcFlag
        ++ ",1 "
        ++ toString x2
        ++ ","
        ++ toString y2
        ++ " z"


getArcs : PieData -> List (Svg.Svg a)
getArcs dataset =
    List.indexedMap
        (\index datum ->
            let
                dAttribute =
                    { dataset = dataset
                    , datum = datum
                    , index = index
                    , total = getTotalOfPieData dataset
                    }
                        |> getArc
                        |> arcToPath
                        |> Svg.Attributes.d
            in
                Svg.path [ Svg.Attributes.fill datum.color, dAttribute ] []
        )
        dataset


{-| Draws a pie chart of given diameter of the dataset.

    Pie.pie 300 [{color = "#0ff", value = 3}, {color = "purple", value = 27}]

-}
pie : Int -> PieData -> Html msg
pie diameter dataset =
    let
        diameterString =
            toString diameter
    in
        div
            [ HA.style
                [ ( "margin-left", "5em" )
                , ( "align", "center" )
                , ( "vertical-align", "middle" )
                ]
            ]
            [ div [ HA.style [ ( "float", "left" ), ( "margin", "1em" ) ] ]
                [ Svg.svg
                    [ Svg.Attributes.viewBox "-0.5 -0.5 1 1"
                    , Svg.Attributes.width diameterString
                    , Svg.Attributes.height diameterString
                    , Svg.Attributes.style
                        "transform: rotate(-90deg)"
                    ]
                    (getArcs dataset)
                ]
            , div
                [ HA.style [ ( "text-align", "left" ), ( "padding-top", "2em" ) ]
                ]
                (pieLegend dataset)
            ]


pieLegend : PieData -> List (Html msg)
pieLegend dataset =
    List.map legendDiv dataset


legendDiv : PieDatum -> Html msg
legendDiv datum =
    div
        [ HA.style [ ( "vertical-align", "middle" ) ] ]
        [ div
            [ HA.style
                [ ( "background-color", datum.color )
                , ( "width", "15px" )
                , ( "height", "15px" )
                , ( "display", "inline-block" )
                , ( "vertical-align", "middle" )
                ]
            ]
            []
        , div
            [ HA.style
                [ ( "display", "inline-block" )
                , ( "vertical-align", "middle" )
                , ( "padding-left", "1em" )
                ]
            ]
            [ Html.text <| datum.legend ++ " " ++ toString (floor datum.value) ]
        ]
