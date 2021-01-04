module Simplegamedev20190510 exposing
    ( composeSimpleGame, SimpleGame, SimpleGameComposition, KeyboardEvent
    , listRemoveSet, listDictGet, svgRectFrom_Fill_Left_Top_Width_Height
    )

{-| This library helps you get implement your video game as simple as possible.


# Composing the App

@docs composeSimpleGame, SimpleGame, SimpleGameComposition, KeyboardEvent


# Common Helpers

Following are generic helper functions which are not specific to one particular game.

@docs listRemoveSet, listDictGet, svgRectFrom_Fill_Left_Top_Width_Height

-}

import Browser
import Browser.Events
import Html
import Json.Decode
import Keyboard.Event
import Svg
import Svg.Attributes
import Time



{-
   Provide a framework so beginners can start developing a game with less effort.
   Take care of the subscriptions and the overall update function, and provide an interface with nice names for the update functions for specific kinds of events.
-}


{-| Use this function to describe how your game is composed of the specific functions in your project.
Following is an example:

    game : SimpleGame GameState ()
    game =
        composeSimpleGame
            { updateIntervalInMilliseconds = 125
            , updatePerInterval = updatePerInterval
            , updateOnKeyDown = updateOnKeyDown
            , updateOnKeyUp = updateOnKeyUp
            , renderToHtml = renderToHtml
            , initialState = initialGameState
            , updateForEventFromHtml = updateForEventFromHtml
            }

-}
composeSimpleGame :
    SimpleGameComposition appState eventFromHtml
    -> Program () appState (SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml)
composeSimpleGame appConfig =
    Browser.element
        { init = always ( appConfig.initialState, Cmd.none )
        , view = appConfig.renderToHtml >> Html.map EventFromHtml
        , update = \event model -> ( simpleGameWithKeyboardInputAndFixedUpdateIntervalUpdate appConfig event model, Cmd.none )
        , subscriptions = simpleGameWithKeyboardInputAndFixedUpdateIntervalSubscriptions appConfig
        }


{-| Describes how your game app is composed of functions that describe how to handle the different kinds of events like for example, pressing or releasing key.
-}
type alias SimpleGameComposition appState eventFromHtml =
    { updateIntervalInMilliseconds : Int
    , updatePerInterval : appState -> appState
    , updateOnKeyDown : Keyboard.Event.KeyboardEvent -> appState -> appState
    , updateOnKeyUp : Keyboard.Event.KeyboardEvent -> appState -> appState
    , renderToHtml : appState -> Html.Html eventFromHtml
    , updateForEventFromHtml : eventFromHtml -> appState -> appState
    , initialState : appState
    }


{-| This type helps you write a type annotation for the function describing the composition of your game:

    game : SimpleGame GameState ()
    game =
    ....

-}
type alias SimpleGame appState eventFromHtml =
    Program () appState (SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml)


simpleGameWithKeyboardInputAndFixedUpdateIntervalUpdate :
    SimpleGameComposition appState eventFromHtml
    -> SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml
    -> appState
    -> appState
simpleGameWithKeyboardInputAndFixedUpdateIntervalUpdate appConfig event appStateBefore =
    case event of
        KeyDown keyboardEvent ->
            appConfig.updateOnKeyDown keyboardEvent appStateBefore

        KeyUp keyboardEvent ->
            appConfig.updateOnKeyUp keyboardEvent appStateBefore

        ArriveAtTime time ->
            appStateBefore |> appConfig.updatePerInterval

        EventFromHtml eventFromHtml ->
            appStateBefore |> appConfig.updateForEventFromHtml eventFromHtml


simpleGameWithKeyboardInputAndFixedUpdateIntervalSubscriptions :
    SimpleGameComposition appState eventFromHtml
    -> appState
    -> Sub (SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml)
simpleGameWithKeyboardInputAndFixedUpdateIntervalSubscriptions appConfig appState =
    [ Browser.Events.onKeyDown (Keyboard.Event.decodeKeyboardEvent |> Json.Decode.map KeyDown)
    , Time.every (appConfig.updateIntervalInMilliseconds |> toFloat) ArriveAtTime
    ]
        |> Sub.batch


type SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml
    = ArriveAtTime Time.Posix
    | KeyDown Keyboard.Event.KeyboardEvent
    | KeyUp Keyboard.Event.KeyboardEvent
    | EventFromHtml eventFromHtml


{-| This type describes the keyboard events as used in the functions `updateOnKeyDown` and `updateOnKeyUp`.
Use as follows:

    updateOnKeyDown : KeyboardEvent -> GameState -> GameState
    updateOnKeyDown =
    ...

-}
type alias KeyboardEvent =
    Keyboard.Event.KeyboardEvent


{-| Remove a set of values from a list
-}
listRemoveSet : List a -> List a -> List a
listRemoveSet elementsToRemove =
    List.filter (\element -> elementsToRemove |> List.member element |> not)


{-| Get the value matching the given key out of a dictionary.
-}
listDictGet : key -> List ( key, value ) -> Maybe value
listDictGet key =
    List.filterMap
        (\( candidateKey, candidateValue ) ->
            if key == candidateKey then
                Just candidateValue

            else
                Nothing
        )
        >> List.head


{-| Generate the HTML code for a SVG rectangle. This only works when placed in an SVG element.
The follow example shows how to create a red rectangle with the upper left corner at coordinates 10|10, a width of 7 and a height of 4 :

    svgRectFrom_Fill_Left_Top_Width_Height "red" ( 10, 10 ) ( 7, 4 )

-}
svgRectFrom_Fill_Left_Top_Width_Height : String -> ( Int, Int ) -> ( Int, Int ) -> Svg.Svg a
svgRectFrom_Fill_Left_Top_Width_Height fill ( left, top ) ( width, height ) =
    Svg.rect
        [ Svg.Attributes.fill fill
        , Svg.Attributes.x (left |> String.fromInt)
        , Svg.Attributes.y (top |> String.fromInt)
        , Svg.Attributes.width (width |> String.fromInt)
        , Svg.Attributes.height (height |> String.fromInt)
        ]
        []
