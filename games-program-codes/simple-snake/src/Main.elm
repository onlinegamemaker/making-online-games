module Main exposing (main)

import Html
import Html.Attributes
import Keyboard.Key
import SimpleGameDev exposing (listDictGet, listRemoveSet)
import Svg
import Svg.Attributes


worldSizeX : Int
worldSizeX =
    16


worldSizeY : Int
worldSizeY =
    12


type SnakeDirection
    = Up
    | Right
    | Down
    | Left


type alias GameState =
    { snake : Snake
    , appleLocation : Location
    }


type alias Location =
    { x : Int
    , y : Int
    }


type alias Snake =
    { headDirection : SnakeDirection
    , headLocation : Location
    , tailSegments : List Location
    }


main : SimpleGameDev.GameProgram GameState ()
main =
    SimpleGameDev.game
        { initialState = initialState
        , view =
            SimpleGameDev.htmlViewWithoutInputs
                { renderToHtml = renderToHtml }
        , updateBasedOnTime =
            Just
                (SimpleGameDev.updateWithFixedInterval
                    { intervalInMilliseconds = 125
                    , update = moveSnakeForwardOneStep
                    }
                )
        , updateOnKeyDown = Just onKeyDown
        , updateOnKeyUp = Nothing
        }


initialState : GameState
initialState =
    { snake = { headDirection = Right, headLocation = { x = 4, y = 5 }, tailSegments = [ { x = 3, y = 5 } ] }
    , appleLocation = { x = 3, y = 2 }
    }


snakeDirectionFromKeyboardKey : List ( Keyboard.Key.Key, SnakeDirection )
snakeDirectionFromKeyboardKey =
    [ ( Keyboard.Key.W, Up )
    , ( Keyboard.Key.A, Left )
    , ( Keyboard.Key.S, Down )
    , ( Keyboard.Key.D, Right )
    , ( Keyboard.Key.Up, Up )
    , ( Keyboard.Key.Down, Down )
    , ( Keyboard.Key.Left, Left )
    , ( Keyboard.Key.Right, Right )
    ]


onKeyDown : SimpleGameDev.KeyboardEventStructure -> GameState -> GameState
onKeyDown keyboardEvent gameStateBefore =
    case snakeDirectionFromKeyboardKey |> listDictGet keyboardEvent.keyCode of
        Nothing ->
            gameStateBefore

        Just snakeDirection ->
            let
                snakeBefore =
                    gameStateBefore.snake
            in
            { gameStateBefore | snake = { snakeBefore | headDirection = snakeDirection } }


xyOffsetFromDirection : SnakeDirection -> { x : Int, y : Int }
xyOffsetFromDirection direction =
    case direction of
        Up ->
            { x = 0, y = -1 }

        Down ->
            { x = 0, y = 1 }

        Left ->
            { x = -1, y = 0 }

        Right ->
            { x = 1, y = 0 }


moveSnakeForwardOneStep : GameState -> GameState
moveSnakeForwardOneStep gameStateBefore =
    let
        snakeBefore =
            gameStateBefore.snake

        headLocationBefore =
            snakeBefore.headLocation

        headMovement =
            xyOffsetFromDirection snakeBefore.headDirection

        headLocationBeforeWrapping =
            { x = headLocationBefore.x + headMovement.x
            , y = headLocationBefore.y + headMovement.y
            }

        headLocation =
            { x = (headLocationBeforeWrapping.x + worldSizeX) |> modBy worldSizeX
            , y = (headLocationBeforeWrapping.y + worldSizeY) |> modBy worldSizeY
            }

        snakeEats =
            headLocation == gameStateBefore.appleLocation

        tailSegmentsIfSnakeWereGrowing =
            headLocationBefore :: snakeBefore.tailSegments

        tailSegments =
            tailSegmentsIfSnakeWereGrowing
                |> List.reverse
                |> List.drop
                    (if snakeEats then
                        0

                     else
                        1
                    )
                |> List.reverse

        appleLocation =
            if not snakeEats then
                gameStateBefore.appleLocation

            else
                let
                    cellsLocationsWithoutSnake =
                        List.range 0 (worldSizeX - 1)
                            |> List.concatMap
                                (\x ->
                                    List.range 0 (worldSizeY - 1)
                                        |> List.map (\y -> { x = x, y = y })
                                )
                            |> listRemoveSet (headLocation :: tailSegments)
                in
                cellsLocationsWithoutSnake
                    |> List.drop (15485863 |> modBy ((cellsLocationsWithoutSnake |> List.length) - 1))
                    |> List.head
                    |> Maybe.withDefault { x = -1, y = -1 }
    in
    { gameStateBefore
        | snake = { snakeBefore | headLocation = headLocation, tailSegments = tailSegments }
        , appleLocation = appleLocation
    }


renderToHtml : GameState -> Html.Html ()
renderToHtml gameState =
    let
        cellSideLength =
            30

        svgRectangleAtCellLocation fill cellLocation =
            SimpleGameDev.svgRectangle
                { fill = fill }
                { left = cellLocation.x * cellSideLength + 1
                , top = cellLocation.y * cellSideLength + 1
                , width = cellSideLength - 2
                , height = cellSideLength - 2
                }

        snakeView =
            gameState.snake.headLocation
                :: gameState.snake.tailSegments
                |> List.map (svgRectangleAtCellLocation "whitesmoke")
                |> Svg.g []

        appleView =
            svgRectangleAtCellLocation "red" gameState.appleLocation
    in
    Svg.svg
        [ Svg.Attributes.width (worldSizeX * cellSideLength |> String.fromInt)
        , Svg.Attributes.height (worldSizeY * cellSideLength |> String.fromInt)
        , Html.Attributes.style "background" "black"
        ]
        [ snakeView, appleView ]
