module Main exposing (main)

import Keyboard.Key
import Playground
import SimpleGameDev exposing (listDictGet, listRemoveSet)


worldSizeCells : { x : Int, y : Int }
worldSizeCells =
    { x = 16, y = 12 }


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
        , view = SimpleGameDev.pictureView renderToPicture
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
            { x = (headLocationBeforeWrapping.x + worldSizeCells.x) |> modBy worldSizeCells.x
            , y = (headLocationBeforeWrapping.y + worldSizeCells.y) |> modBy worldSizeCells.y
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
                        List.range 0 (worldSizeCells.x - 1)
                            |> List.concatMap
                                (\x ->
                                    List.range 0 (worldSizeCells.y - 1)
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


renderToPicture : GameState -> SimpleGameDev.PictureViewResult
renderToPicture gameState =
    let
        cellSideLength =
            30

        worldWidth =
            cellSideLength * toFloat worldSizeCells.x

        worldHeight =
            cellSideLength * toFloat worldSizeCells.y

        rectangleAtCellLocation fill cellLocation =
            Playground.rectangle fill (cellSideLength - 2) (cellSideLength - 2)
                |> Playground.moveRight ((toFloat cellLocation.x + 0.5) * cellSideLength - worldWidth / 2)
                |> Playground.moveDown ((toFloat cellLocation.y + 0.5) * cellSideLength - worldHeight / 2)

        worldShape =
            Playground.rectangle Playground.black worldWidth worldHeight

        snakeShape =
            gameState.snake.headLocation
                :: gameState.snake.tailSegments
                |> List.map (rectangleAtCellLocation Playground.lightGrey)
                |> Playground.group

        appleShape =
            rectangleAtCellLocation Playground.red gameState.appleLocation
    in
    { shapes = [ worldShape, snakeShape, appleShape ]
    , viewport = { width = worldWidth, height = worldHeight }
    , backgroundColor = Playground.darkCharcoal
    }
