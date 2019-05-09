module Simplegamedev20190509 exposing
    ( listDictGet
    , listRemoveSet
    , svgRectFrom_Fill_Left_Top_Width_Height
    )

import Svg
import Svg.Attributes


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
