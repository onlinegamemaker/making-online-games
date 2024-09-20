module Build exposing (..)

import Bytes
import Bytes.Encode
import CompilationInterface.ElmMake
import CompilationInterface.SourceFiles


replacements : List ( String, String )
replacements =
    [ ( String.trim
            """
            <script type="text/javascript" src="elm-app-identifier.js"></script>
            """
      , "<script type=\"text/javascript\" src=\"data:text/javascript;base64,"
            ++ CompilationInterface.ElmMake.elm_make____src_ElmApp_elm.javascript.base64
            ++ "\"></script>"
      )
    ]


composedHtml : String
composedHtml =
    List.foldl
        (\( from, to ) html ->
            String.replace from to html
        )
        CompilationInterface.SourceFiles.file____Container_html.utf8
        replacements


blobMain : Bytes.Bytes
blobMain =
    Bytes.Encode.encode
        (Bytes.Encode.string composedHtml)
