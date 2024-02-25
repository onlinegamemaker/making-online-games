module Main exposing (..)

{-
   For more examples, including complete games, see <https://github.com/onlinegamemaker/making-online-games>
-}

import Css
import Html
import Html.Styled
import Html.Styled.Attributes


type alias ExampleEntry =
    { name : String
    , url : String
    }


exampleEntries : List ExampleEntry
exampleEntries =
    [ { name = "Counter Buttons"
      , url = "https://elm-editor.com/?project-state=https%3A%2F%2Fgithub.com%2Fonlinegamemaker%2Fmaking-online-games%2Ftree%2Fmain%2Fimplement%2Fdemo%2Fcounter-buttons&file-path-to-open=src%2FCounterButtonsMain.elm"
      }
    , { name = "Analog Clock"
      , url = "https://elm-editor.com/?project-state=https%3A%2F%2Fgithub.com%2Fonlinegamemaker%2Fmaking-online-games%2Ftree%2Fmain%2Fimplement%2Fdemo%2Fclock-svg&file-path-to-open=src%2FMain.elm"
      }
    , { name = "Snake Game"
      , url = "https://elm-editor.com/?project-state=https%3A%2F%2Fgithub.com%2Fonlinegamemaker%2Fmaking-online-games%2Ftree%2Fmain%2Fgames-program-codes%2Fsimple-snake&file-path-to-open=src%2FMain.elm"
      }
    , { name = "Game Template"
      , url = "https://elm-editor.com/?project-state=https%3A%2F%2Fgithub.com%2Fonlinegamemaker%2Fmaking-online-games%2Ftree%2Fmain%2Fgames-program-codes%2Fgame-template&file-path-to-open=src%2FMain.elm"
      }
    , { name = "Platformer Game"
      , url = "https://elm-editor.com/?project-state=https%3A%2F%2Fgithub.com%2FViir%2Fsunny-land%2Ftree%2Fd7660f6e6edf099d8d52587224582f235e0f6a4e%2F&file-path-to-open=src%2FMain.elm"
      }
    , { name = "3D Animation"
      , url = "https://elm-editor.com/?project-state=https%3A%2F%2Fgithub.com%2Ferkal%2Felm-3d-playground-exploration%2Ftree%2F448453a7c9341e5abf6d9a64b46de93571fd14f4%2F&file-path-to-open=games%2Frecursive-tree%2Fsrc%2FMain.elm"
      }
    , { name = "More!"
      , url = "https://github.com/onlinegamemaker/making-online-games"
      }
    ]


main : Html.Html a
main =
    let
        examplesElement =
            exampleEntries
                |> List.map
                    (\entry ->
                        Html.Styled.li
                            [ Html.Styled.Attributes.css
                                [ Css.margin (Css.px 10) ]
                            ]
                            [ Html.Styled.a
                                [ Html.Styled.Attributes.href entry.url
                                , Html.Styled.Attributes.css linkStyle
                                ]
                                [ Html.Styled.text entry.name ]
                            ]
                    )
                |> Html.Styled.ul
                    [ Html.Styled.Attributes.css
                        [ Css.padding (Css.px 0)
                        , Css.margin (Css.em 1)
                        ]
                    ]
    in
    Html.Styled.div
        [ Html.Styled.Attributes.css
            [ Css.fontFamilies [ "Open Sans", "Arial" ]
            , Css.backgroundColor (Css.rgb 30 30 30)
            , Css.color (Css.rgb 230 230 230)
            , Css.width (Css.vw 100)
            , Css.height (Css.vh 100)
            , Css.overflow Css.hidden
            ]
        , Html.Styled.Attributes.style "display" "grid"
        , Html.Styled.Attributes.style "place-content" "center"
        ]
        [ Html.Styled.h1
            [ Html.Styled.Attributes.css
                [ Css.fontWeight Css.normal
                ]
            ]
            [ Html.Styled.text "Examples" ]
        , examplesElement
        , Html.Styled.div [] []
        ]
        |> Html.Styled.toUnstyled


linkStyle : List Css.Style
linkStyle =
    [ Css.link
        [ Css.color linkColor
        , Css.textDecoration Css.none
        ]
    , Css.visited
        [ Css.color linkColor
        ]
    , Css.active
        [ Css.color linkColor
        ]
    , Css.hover
        [ Css.textDecoration Css.underline
        ]
    ]


linkColor : Css.Color
linkColor =
    Css.hsl 208 0.97 0.65
