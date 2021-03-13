module SimpleGameDev exposing
    ( composeSimpleGame, SimpleGame, SimpleGameComposition
    , svgRectangle, listRemoveSet, listDictGet
    , KeyboardEventStructure
    )

{-| This module provides a framework to build video games as well as a library of standard helper functions.
The framework wraps the more general Elm program type with an interface optimized for video games.


# Composing the App

@docs composeSimpleGame, SimpleGame, SimpleGameComposition, KeyboardEvent


# Common Helpers

Following are generic helper functions which are not specific to one particular game.

@docs svgRectangle, listRemoveSet, listDictGet

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
        , view = appConfig.renderToHtml >> Html.map FromHtmlEvent
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
        KeyDownEvent keyDown ->
            appConfig.updateOnKeyDown keyDown appStateBefore

        KeyUpEvent keyUp ->
            appConfig.updateOnKeyUp keyUp appStateBefore

        TimeArrivedEvent _ ->
            appStateBefore |> appConfig.updatePerInterval

        FromHtmlEvent fromHtmlEvent ->
            appStateBefore |> appConfig.updateForEventFromHtml fromHtmlEvent


simpleGameWithKeyboardInputAndFixedUpdateIntervalSubscriptions :
    SimpleGameComposition appState eventFromHtml
    -> appState
    -> Sub (SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml)
simpleGameWithKeyboardInputAndFixedUpdateIntervalSubscriptions appConfig _ =
    [ Browser.Events.onKeyDown (Keyboard.Event.decodeKeyboardEvent |> Json.Decode.map KeyDownEvent)
    , Time.every (appConfig.updateIntervalInMilliseconds |> toFloat) TimeArrivedEvent
    ]
        |> Sub.batch


type SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml
    = TimeArrivedEvent Time.Posix
    | KeyDownEvent KeyboardEventStructure
    | KeyUpEvent KeyboardEventStructure
    | FromHtmlEvent eventFromHtml


{-| This type describes the keyboard events as used in the functions `updateOnKeyDown` and `updateOnKeyUp`.
Use as follows:

    updateOnKeyDown : KeyboardEvent -> GameState -> GameState
    updateOnKeyDown =
    ...

-}
type alias KeyboardEventStructure =
    Keyboard.Event.KeyboardEvent


{-| Generate the HTML code for an SVG rectangle. Note the rectangle will only be visible when placed in an SVG element.
Following is an example of how to use it:

    svgRectangle { fill = "red" } { left = 10, top = 10, width = 7, height = 4 }

-}
svgRectangle : { fill : String } -> { left : Int, top : Int, width : Int, height : Int } -> Svg.Svg a
svgRectangle { fill } { left, top, width, height } =
    Svg.rect
        [ Svg.Attributes.fill fill
        , Svg.Attributes.x (left |> String.fromInt)
        , Svg.Attributes.y (top |> String.fromInt)
        , Svg.Attributes.width (width |> String.fromInt)
        , Svg.Attributes.height (height |> String.fromInt)
        ]
        []


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
