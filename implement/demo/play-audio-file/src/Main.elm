{-
   This app demonstrates how to control starting playback of audio in the update function of an Elm program.
   It also offers the user to configure the URL to the audio file and the playback volume via the HTML GUI.
   Since it's pure Elm and does not rely on ports, it also works in environments like https://elm-lang.org/try
-}


module Main exposing (main)

import Browser
import Html
import Html.Attributes as HA
import Html.Events
import Json.Encode


type alias PlaybackParams =
    { sourceUrl : String
    , volume : Float
    }


type alias State =
    { selectedPlaybackParams : PlaybackParams
    , startedPlaybacks : List PlaybackParams
    }


type Event
    = SelectAudioSourceUrl String
    | SelectPlaybackVolume Float
    | StartPlayback


init : State
init =
    { selectedPlaybackParams =
        { sourceUrl = "http://dict.leo.org/media/audio/ZXOapx_FyRojukaMRHKS_w.mp3"
        , volume = 0.7
        }
    , startedPlaybacks = []
    }


main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


playbackView : PlaybackParams -> Html.Html event
playbackView playbackParams =
    Html.audio
        [ HA.controls False
        , HA.autoplay True
        , HA.property "volume" (Json.Encode.string (String.fromFloat playbackParams.volume))
        ]
        [ Html.source [ HA.src playbackParams.sourceUrl ] [] ]


view : State -> Html.Html Event
view state =
    let
        selectedPlaybackParams =
            state.selectedPlaybackParams

        selectedSourceUrl =
            selectedPlaybackParams.sourceUrl

        selectedPlaybackVolume =
            selectedPlaybackParams.volume
    in
    Html.div
        [ HA.style "background-color" "hsl(0, 0%, 10%)"
        , HA.style "color" "hsl(0, 0%, 90%)"
        , HA.style "padding" "1em"
        , HA.style "font-family" "sans-serif"
        ]
        [ Html.div []
            [ Html.text "configure audio parameters"
            , Html.div [ HA.style "margin" "10px" ]
                [ Html.div [] [ Html.text "url to audio file" ]
                , Html.div []
                    [ Html.input
                        [ HA.placeholder "url to audio file"
                        , Html.Events.onInput SelectAudioSourceUrl
                        , HA.value selectedSourceUrl
                        ]
                        []
                    ]
                , Html.div [] [ Html.text "-" ]
                , Html.div [] [ Html.text "playback volume" ]
                , Html.div []
                    [ Html.input
                        [ HA.type_ "range"
                        , HA.min "0"
                        , HA.max "100"
                        , HA.value <| String.fromFloat (selectedPlaybackVolume * 100)
                        , Html.Events.onInput (String.toFloat >> Maybe.withDefault 40 >> (*) 0.01 >> SelectPlaybackVolume)
                        ]
                        []
                    , Html.text <| (((selectedPlaybackVolume * 100) |> round |> String.fromInt) ++ "%")
                    ]
                ]
            , Html.button [ Html.Events.onClick StartPlayback ] [ Html.text "click to start playback" ]
            ]
        , Html.div [] [ Html.text "-" ]
        , Html.div [] [ Html.text (String.fromInt (state.startedPlaybacks |> List.length) ++ " playbacks started") ]
        , Html.div [] (state.startedPlaybacks |> List.map playbackView)
        ]


startPlayback : State -> State
startPlayback state =
    { state | startedPlaybacks = state.startedPlaybacks ++ [ state.selectedPlaybackParams ] }


updatePlaybackParams : Event -> PlaybackParams -> PlaybackParams
updatePlaybackParams event playbackParams =
    case event of
        SelectAudioSourceUrl url ->
            { playbackParams | sourceUrl = url }

        SelectPlaybackVolume volume ->
            { playbackParams | volume = volume }

        _ ->
            playbackParams


update : Event -> State -> State
update event state =
    let
        withPlaybackParams =
            { state | selectedPlaybackParams = updatePlaybackParams event state.selectedPlaybackParams }
    in
    case event of
        StartPlayback ->
            startPlayback withPlaybackParams

        SelectPlaybackVolume volume ->
            { withPlaybackParams | startedPlaybacks = state.startedPlaybacks |> List.map (withVolume volume) }

        _ ->
            withPlaybackParams


withVolume : Float -> PlaybackParams -> PlaybackParams
withVolume volume paramsBefore =
    { paramsBefore | volume = volume }
