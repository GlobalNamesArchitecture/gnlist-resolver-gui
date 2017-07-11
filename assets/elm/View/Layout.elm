module View.Layout exposing (layout)

import Html exposing (..)
import Html.Attributes exposing (class, href, id, style)
import I18n exposing (Translation(..))
import Models exposing (Model)


layout : Model -> Html a -> Html a
layout { softwareVersion } contents =
    div []
        [ pageHeader
        , div [ class "container" ] [ div [ id "content" ] [ contents ] ]
        , pageFooter softwareVersion
        ]


pageHeader : Html a
pageHeader =
    div [ class "container" ]
        [ div [ class "header" ]
            [ h1 [ id "title" ]
                [ a [ href "/" ] [ text <| I18n.t ApplicationName ]
                ]
            , div [ class "menu" ]
                [ ul []
                    [ li []
                        [ a [ href "/" ] [ text <| I18n.t HomeLinkText ]
                        ]
                    ]
                ]
            ]
        ]


licenseUrl : String
licenseUrl =
    "https://github.com/GlobalNamesArchitecture/gnlist-resolver-gui/blob/master/LICENSE"


releasesUrl : String
releasesUrl =
    "https://github.com/GlobalNamesArchitecture/gnlist-resolver-gui/releases"


pageFooter : String -> Html a
pageFooter version =
    div [ class "container" ]
        [ div [ id "footer", style [ ( "padding-left", "21.5em" ) ] ]
            [ a [ href licenseUrl ] [ text <| I18n.t MITLicense ]
            , text " | "
            , a [ href releasesUrl ] [ text <| I18n.t Version ++ " " ++ version ]
            ]
        ]
