This package supports the simple development of video games in [Ellie](https://github.com/ellie-app/ellie/issues/94#issuecomment-487252060). 

The functions contained in this package make it easier to create a browser app and provide implementations for commonly used generic functionality.

The `composeSimpleGame` function provides a way to create a complete browser application without having to learn about subscriptions or how to combine the different kinds of updates into a single update function.
The following code example shows how it is used to compose a game app:

```elm
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

```
