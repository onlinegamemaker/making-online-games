module CompilationInterface.SourceFiles exposing (..)

{-| For documentation of the compilation interface, see <https://github.com/pine-vm/pine/blob/main/guide/how-to-use-elm-compilation-interfaces.md#compilationinterfacesourcefiles-elm-module>
-}


type FileTreeNode blobStructure
    = BlobNode blobStructure
    | TreeNode (List ( String, FileTreeNode blobStructure ))


file____Container_html : { utf8 : String }
file____Container_html =
    { utf8 = "The compiler replaces this declaration." }
