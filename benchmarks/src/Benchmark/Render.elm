port module Benchmark.Render exposing (Benchmark, toProgram)

{-| This is the rendering harness. The actual cases are in `src`.
-}

import Browser
import Browser.Events
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Decode
import Json.Encode as Encode
import Time


type alias Benchmark model msg =
    { name : String
    , init : model
    , view : model -> Html Msg
    , update : msg -> model -> model
    , tick : Float -> msg
    , refresh : msg
    }


type alias Model model =
    { model : model
    , animating : Bool
    , frames : List Float
    }


type Msg
    = Tick Float
    | Refresh
    | Received Encode.Value
    | StartAnim
    | StopAnim


toProgram : Benchmark model msg -> Program () (Model model) Msg
toProgram render =
    Browser.document
        { init =
            \() ->
                ( { model = render.init
                  , animating = False
                  , frames = []
                  }
                , Cmd.none
                )
        , view =
            \model ->
                { title = render.name
                , body =
                    [ Html.div
                        [ Attr.style "display" "flex"
                        , Attr.style "flex-direction" "row"
                        ]
                        [ Html.button [ Events.onClick Refresh ] [ Html.text "Refresh" ]
                        , Html.button [ Events.onClick StartAnim ] [ Html.text "StartAnim" ]
                        , Html.button [ Events.onClick StopAnim ] [ Html.text "StopAnim" ]
                        ]
                    , render.view model.model
                    ]
                }
        , update =
            update render
        , subscriptions =
            \model ->
                Sub.batch
                    [ worldToElm Received
                    , if model.animating then
                        Browser.Events.onAnimationFrameDelta Tick

                      else
                        Sub.none
                    ]
        }


update : Benchmark model msg -> Msg -> Model model -> ( Model model, Cmd Msg )
update render msg model =
    case msg of
        StartAnim ->
            ( { model | animating = True }
            , Cmd.none
            )

        StopAnim ->
            ( { model | animating = False }
            , elmToWorld (encodeMetrics render.name model.frames)
            )

        Refresh ->
            ( { model | model = render.update render.refresh model.model }
            , Cmd.none
            )

        Tick time ->
            ( { model
                | model = render.update (render.tick time) model.model
                , frames = time :: model.frames
              }
            , Cmd.none
            )

        Received json ->
            case Decode.decodeValue outsideMsg json of
                Err err ->
                    ( model, Cmd.none )

                Ok newMsg ->
                    update render newMsg model


outsideMsg =
    Decode.field "tag" Decode.string
        |> Decode.andThen
            (\tag ->
                case tag of
                    "Refresh" ->
                        Decode.succeed Refresh

                    "StartAnim" ->
                        Decode.succeed StartAnim

                    "StopAnim" ->
                        Decode.succeed StopAnim

                    _ ->
                        Decode.fail "Unknown incoming msg"
            )


encodeMetrics name frames =
    Encode.object
        [ ( "name", Encode.string name )
        , ( "frames"
          , Encode.list Encode.float frames
          )
        ]


port worldToElm : (Encode.Value -> msg) -> Sub msg


port elmToWorld : Encode.Value -> Cmd msg
