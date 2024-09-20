module ElmApp exposing (..)

{-| The `custom-html-container` demo implements a build process to contain the Elm app in a custom HTML document.
-}

import Browser
import Html
import Html.Attributes
import Html.Events


type alias Flags =
    String


type alias State =
    Int


type Event
    = Increment
    | Decrement


main : Program Flags State Event
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }


init : Flags -> ( State, Cmd Event )
init flags =
    ( case String.toInt flags of
        Nothing ->
            17

        Just fromFlags ->
            fromFlags
    , Cmd.none
    )


update : Event -> State -> ( State, Cmd Event )
update event state =
    case event of
        Increment ->
            ( state + 1
            , Cmd.none
            )

        Decrement ->
            ( state - 1
            , Cmd.none
            )


view : State -> Html.Html Event
view state =
    Html.div
        [ Html.Attributes.style "background" "#333"
        , Html.Attributes.style "color" "whitesmoke"
        , Html.Attributes.style "font-size" "200%"
        , Html.Attributes.style "display" "grid"
        , Html.Attributes.style "place-content" "center"
        , Html.Attributes.style "width" "100vw"
        , Html.Attributes.style "height" "100vh"
        , Html.Attributes.style "overflow" "hidden"
        ]
        [ Html.button
            [ Html.Events.onClick Decrement
            , Html.Attributes.style "font-weight" "bold"
            , Html.Attributes.style "font-size" "150%"
            ]
            [ Html.text "-" ]
        , Html.div
            [ Html.Attributes.style "display" "inline-block"
            , Html.Attributes.style "padding" "1em 1em"
            ]
            [ Html.text (String.fromInt state) ]
        , Html.button
            [ Html.Events.onClick Increment
            , Html.Attributes.style "font-weight" "bold"
            , Html.Attributes.style "font-size" "150%"
            ]
            [ Html.text "+" ]
        ]
