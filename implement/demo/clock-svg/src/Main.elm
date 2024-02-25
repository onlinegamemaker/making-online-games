module Main exposing (..)

{-
   This app displays an analog clock for your time zone.

   For more examples, including complete games, see <https://github.com/onlinegamemaker/making-online-games>
-}

import Browser
import Html
import Html.Attributes
import Svg
import Svg.Attributes
import Task
import Time


main : Program () State Event
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias State =
    { zone : Time.Zone
    , time : Time.Posix
    }


type Event
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone


init : () -> ( State, Cmd Event )
init _ =
    ( State Time.utc (Time.millisToPosix 0)
    , Cmd.batch
        [ Task.perform AdjustTimeZone Time.here
        , Task.perform Tick Time.now
        ]
    )


update : Event -> State -> ( State, Cmd Event )
update event state =
    case event of
        Tick newTime ->
            ( { state | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newZone ->
            ( { state | zone = newZone }
            , Cmd.none
            )


subscriptions : State -> Sub Event
subscriptions state =
    Time.every 1000 Tick


view : State -> Html.Html e
view state =
    Html.div
        [ Html.Attributes.style "width" "100vw"
        , Html.Attributes.style "height" "100vh"
        , Html.Attributes.style "overflow" "hidden"
        , Html.Attributes.style "background-color" "#333"
        , Html.Attributes.style "display" "grid"
        , Html.Attributes.style "place-content" "center"
        ]
        [ viewClockSvg state ]


viewClockSvg : State -> Html.Html e
viewClockSvg state =
    let
        hour =
            toFloat (Time.toHour state.zone state.time)

        minute =
            toFloat (Time.toMinute state.zone state.time)

        second =
            toFloat (Time.toSecond state.zone state.time)
    in
    Svg.svg
        [ Svg.Attributes.viewBox "0 0 400 400"
        , Svg.Attributes.width "400"
        , Svg.Attributes.height "400"
        ]
        [ Svg.circle
            [ Svg.Attributes.cx "200"
            , Svg.Attributes.cy "200"
            , Svg.Attributes.r "120"
            , Svg.Attributes.fill "#1293D8"
            ]
            []
        , viewHand 6 60 (hour / 12)
        , viewHand 6 90 (minute / 60)
        , viewHand 3 90 (second / 60)
        ]


viewHand : Int -> Float -> Float -> Svg.Svg e
viewHand width length turns =
    let
        t =
            2 * pi * (turns - 0.25)

        x =
            200 + length * cos t

        y =
            200 + length * sin t
    in
    Svg.line
        [ Svg.Attributes.x1 "200"
        , Svg.Attributes.y1 "200"
        , Svg.Attributes.x2 (String.fromFloat x)
        , Svg.Attributes.y2 (String.fromFloat y)
        , Svg.Attributes.stroke "white"
        , Svg.Attributes.strokeWidth (String.fromInt width)
        , Svg.Attributes.strokeLinecap "round"
        ]
        []
