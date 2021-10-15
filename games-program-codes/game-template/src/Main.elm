module Main exposing (main)

{- This project is a template for video games.
   It comes with a framework for rendering to HTML (web browsers) and processing inputs from the keyboard or the mouse.
   You can use this as a starting point for games like Tic-Tac-Toe, Snake, Tetris, Breakout, or platformers like Super Mario.

   For examples, including complete games, see https://github.com/onlinegamemaker/making-online-games
-}

import Keyboard.Key
import Playground
import SimpleGameDev


type alias GameState =
    { toggled : Bool }


main : SimpleGameDev.GameProgram GameState
main =
    SimpleGameDev.game
        { initialState = initialState
        , view = SimpleGameDev.pictureView renderToPicture
        , updateBasedOnTime = Nothing
        , updateOnKeyDown = Nothing
        , updateOnKeyUp = Nothing
        }


initialState : GameState
initialState =
    { toggled = False }


renderToPicture : GameState -> SimpleGameDev.PictureViewResult GameState
renderToPicture gameState =
    { shapes =
        [ Playground.group
            [ Playground.triangle Playground.green 150
            , Playground.circle Playground.white 40
            , Playground.circle Playground.black 10
                |> Playground.move -14 11
            , (if gameState.toggled then
                Playground.rectangle Playground.lightBlue 60 60

               else
                Playground.rectangle Playground.darkOrange 40 40
              )
                |> Playground.moveUp 110
                |> Playground.moveLeft 140
                |> Playground.rotate 45
                |> Playground.reactOnClick shapeClicked
            ]
        ]
    , viewport = { width = 400, height = 400 }
    , backgroundColor = Playground.darkCharcoal
    }


shapeClicked : GameState -> GameState
shapeClicked gameStateBeforeClicked =
    { gameStateBeforeClicked | toggled = not gameStateBeforeClicked.toggled }
