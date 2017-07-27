module View.Layout exposing (layout, contentWrapper, styledButton, buttonStyles)

import Material.Layout as Layout
import Material.Options as Options
import Material.Typography as Typo
import Material.Elevation as Elevation
import Material.Color as Color
import Html exposing (Html, Attribute, h2, h3, text, button, img)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Widgets.BreadCrumbs as Breadcrumbs
import Markdown
import I18n exposing (Translation(..))
import Models exposing (Model)
import Messages exposing (Msg(Mdl))


layout : Model -> List (Html Msg) -> Html Msg
layout ({ mdl, softwareVersion } as model) content =
    Layout.render Mdl
        mdl
        [ Layout.fixedHeader
        ]
        { header = pageHeader softwareVersion
        , drawer = []
        , tabs = ( [], [] )
        , main =
            [ Options.div [] [ Breadcrumbs.view model ]
            , Options.div [ Elevation.e2, Options.cs "container" ]
                [ Options.div [ Options.cs "container__content" ] content
                ]
            ]
        }


contentWrapper : Translation b -> Translation b -> List (Html a) -> Html a
contentWrapper headerTranslation bodyTranslation content =
    let
        heading =
            Options.styled h2 [ Typo.display1 ] [ text <| I18n.t headerTranslation ]

        description =
            Markdown.toHtml [] <| I18n.t bodyTranslation
    in
        Options.div [] <| heading :: description :: content


buttonStyles : Attribute a
buttonStyles =
    class "mdl-button mdl-js-button mdl-button--raised mdl-js-ripple-effect mdl-button--accent"


styledButton : List (Attribute a) -> a -> Translation b -> Html a
styledButton options f translation =
    button (buttonStyles :: onClick f :: options) [ text <| I18n.t translation ]


whiteBackground : Options.Property a b
whiteBackground =
    Color.background Color.white


darkText : Options.Property a b
darkText =
    Color.text Color.primaryDark


pageHeader : String -> List (Html Msg)
pageHeader version =
    [ Layout.row [ whiteBackground, darkText, Elevation.e4 ]
        [ Layout.navigation []
            [ Layout.title [ Options.cs "title__anchor" ]
                [ Layout.link [ darkText, Layout.href "/" ]
                    [ img [ src "static/img/catalogue-of-life.gif" ] []
                    , Options.span [ Typo.title ] [ text <| I18n.t ApplicationName ]
                    ]
                ]
            ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link [ darkText, Layout.href licenseUrl ] [ text <| I18n.t MITLicense ]
            , Layout.link [ darkText, Layout.href releasesUrl ] [ text <| I18n.t Version ++ " " ++ version ]
            ]
        ]
    ]


licenseUrl : String
licenseUrl =
    "https://github.com/GlobalNamesArchitecture/gnlist-resolver-gui/blob/master/LICENSE"


releasesUrl : String
releasesUrl =
    "https://github.com/GlobalNamesArchitecture/gnlist-resolver-gui/releases"


drawer : String -> List (Html a)
drawer softwareVersion =
    [ Layout.navigation []
        [ Layout.link [ Layout.href "/" ] [ text <| I18n.t BreadcrumbUploadFile ]
        , Layout.link [ Layout.href licenseUrl ] [ text <| I18n.t MITLicense ]
        , Layout.link [ Layout.href releasesUrl ] [ text <| I18n.t Version ++ " " ++ softwareVersion ]
        ]
    ]
