module Widgets.Slider exposing (Datum, slider)

import Html
import Svg exposing (..)
import Svg.Attributes as SA exposing (..)


type alias Datum =
    { total : Float
    , part : Float
    }


slider : Datum -> Html.Html msg
slider data =
    let
        length =
            400.0

        percent =
            (data.total / data.part) * length
    in
        Html.div []
            [ Svg.svg
                [ SA.width <| toString (length + 100) ++ "px"
                , SA.height "40px"
                , viewBox "-10 -5 500 40"
                ]
                [ defs []
                    [ linearGradient
                        [ SA.id "darkFaderGradient"
                        , gradientUnits "objectBoundingBox"
                        , x2 "0"
                        , y2 "1"
                        ]
                        [ stop [ offset "0", stopColor "#0f0" ] []
                        , stop [ offset "1", stopColor "#080" ] []
                        ]
                    , linearGradient
                        [ SA.id "lightFaderGradient"
                        , gradientUnits "objectBoundingBox"
                        , x2 "0"
                        , y2 "1"
                        ]
                        [ stop [ offset "0", stopColor "white" ] []
                        , stop [ offset "1", stopColor "#D7D9DC" ] []
                        ]
                    ]
                , g []
                    [ g [ SA.id "fader", SA.style "stroke:#989B9F" ]
                        [ rect
                            [ SA.class "faderBackground"
                            , SA.id "svg01"
                            , rx "10"
                            , SA.height "20"
                            , SA.width (toString length)
                            , SA.style """fill:url(#lightFaderGradient)"""
                            ]
                            []
                        , rect
                            [ SA.class "faderForeground"
                            , SA.id "svg02"
                            , rx "10"
                            , SA.height "20"
                            , SA.width (toString percent)
                            , SA.style """fill:url(#darkFaderGradient)"""
                            ]
                            []
                        ]
                    ]
                ]
            ]
