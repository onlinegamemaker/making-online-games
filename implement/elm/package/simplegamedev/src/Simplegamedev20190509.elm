module Simplegamedev20190509 exposing
    ( SimpleGameWithKeyboardInputAndFixedUpdateInterval
    , listDictGet
    , listRemoveSet
    , simpleGameWithKeyboardInputAndFixedUpdateInterval
    , svgRectFrom_Fill_Left_Top_Width_Height
    )

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


type alias SimpleGameWithKeyboardInputAndFixedUpdateInterval appState eventFromHtml =
    { updateIntervalInMilliseconds : Int
    , updatePerInterval : appState -> appState
    , updateOnKeyDown : Keyboard.Event.KeyboardEvent -> appState -> appState
    , updateOnKeyUp : Keyboard.Event.KeyboardEvent -> appState -> appState
    , renderToHtml : appState -> Html.Html eventFromHtml
    , updateForEventFromHtml : eventFromHtml -> appState -> appState
    , initialState : appState
    }


type SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml
    = ArriveAtTime Time.Posix
    | KeyDown Keyboard.Event.KeyboardEvent
    | KeyUp Keyboard.Event.KeyboardEvent
    | EventFromHtml eventFromHtml


simpleGameWithKeyboardInputAndFixedUpdateInterval :
    SimpleGameWithKeyboardInputAndFixedUpdateInterval appState eventFromHtml
    -> Program () appState (SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml)
simpleGameWithKeyboardInputAndFixedUpdateInterval appConfig =
    Browser.element
        { init = always ( appConfig.initialState, Cmd.none )
        , view = appConfig.renderToHtml >> Html.map EventFromHtml
        , update = \event model -> ( simpleGameWithKeyboardInputAndFixedUpdateIntervalUpdate appConfig event model, Cmd.none )
        , subscriptions = simpleGameWithKeyboardInputAndFixedUpdateIntervalSubscriptions appConfig
        }


simpleGameWithKeyboardInputAndFixedUpdateIntervalUpdate :
    SimpleGameWithKeyboardInputAndFixedUpdateInterval appState eventFromHtml
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
    SimpleGameWithKeyboardInputAndFixedUpdateInterval appState eventFromHtml
    -> appState
    -> Sub (SimpleGameWithKeyboardInputAndFixedUpdateIntervalEvent eventFromHtml)
simpleGameWithKeyboardInputAndFixedUpdateIntervalSubscriptions appConfig appState =
    [ Browser.Events.onKeyDown (Keyboard.Event.decodeKeyboardEvent |> Json.Decode.map KeyDown)
    , Time.every (appConfig.updateIntervalInMilliseconds |> toFloat) ArriveAtTime
    ]
        |> Sub.batch



-- Following are generic helper functions which are not specific to one particular game. Also based on the snake game example as documented at https://ellie-app.com/5nvrmZh8WHca1


listRemoveSet : List a -> List a -> List a
listRemoveSet elementsToRemove =
    List.filter (\element -> elementsToRemove |> List.member element |> not)


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
