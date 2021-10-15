# Game Template

This project is a template for video games.
It comes with a framework for rendering to HTML (web browsers) and processing inputs from the keyboard or the mouse.
You can use this as a starting point for games like Tic-Tac-Toe, Snake, Tetris, Breakout, or platformers like Super Mario.

For examples, including complete games, see https://github.com/onlinegamemaker/making-online-games

For some games, you will want to add time-based updates to the game state. For example, this is the case for the game 'snake'. Here we want to move the player's snake forward based on a time interval.
To enable such a time-based update, use the `updateBasedOnTime` field in the `SimpleGameDev.game` function like this:

```Elm
    updateBasedOnTime =
        Just
            (SimpleGameDev.updateWithFixedInterval
                { intervalInMilliseconds = 125
                , update = moveSnakeForwardOneStep
                }
            )
```

