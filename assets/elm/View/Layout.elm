module View.Layout exposing (layout, contentWrapper)

import Material.Layout as Layout
import Material.Options as Options
import Material.Typography as Typo
import Material.Elevation as Elevation
import Material.Footer as Footer
import Html exposing (Html, h2, h3, text)
import I18n exposing (Translation(..))
import Models exposing (Model)
import Messages exposing (Msg(Mdl))


layout : Model -> List (Html Msg) -> Html Msg
layout { mdl, softwareVersion } content =
    Layout.render Mdl
        mdl
        [ Layout.fixedHeader
        , Layout.scrolling
        ]
        { header = pageHeader
        , drawer = []
        , tabs = ( [], [] )
        , main =
            [ Options.div [ Elevation.e2, Options.cs "container" ]
                [ Options.div [ Options.cs "container__content" ] content
                , pageFooter softwareVersion
                ]
            ]
        }


contentWrapper : Translation b -> List (Html a) -> Html a
contentWrapper translation content =
    let
        heading =
            Options.styled h3 [ Typo.headline ] [ text <| I18n.t translation ]
    in
        Options.div [] <| heading :: content


pageHeader : List (Html Msg)
pageHeader =
    [ Layout.row [ Elevation.e4 ]
        [ Layout.title []
            [ Layout.link [ Layout.href "/" ]
                [ Options.styled h2
                    [ Typo.headline ]
                    [ text <| I18n.t ApplicationName ]
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
    Footer.mini []
        { left =
            Footer.left []
                [ Footer.links []
                    [ Footer.linkItem [ Footer.href licenseUrl ] [ Footer.html <| text <| I18n.t MITLicense ]
                    , Footer.linkItem [ Footer.href releasesUrl ] [ Footer.html <| text <| I18n.t Version ++ " " ++ version ]
                    ]
                ]
        , right = Footer.right [] []
        }
