module Tests.Manual.LazyPerformance exposing (..)

{-

   We want to make sure that lazy is able to perform correctly in style-elements.

   For the setup:

   Render an expensive thing in html.

   Rerender with Lazy.






-}

import Element
import Element.Lazy
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Html.Lazy
import Internal.Model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


init : ( Model, Cmd Msg )
init =
    ( { renderAs = NothingPlease, count = 0 }, Cmd.none )


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { renderAs : Render
    , count : Int
    }


type Render
    = HtmlPlease
    | StylePlease
    | NothingPlease


type Msg
    = RenderAs Render


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RenderAs mode ->
            ( { model
                | renderAs = mode
                , count =
                    if mode == model.renderAs then
                        model.count + 1
                    else
                        0
              }
            , Cmd.none
            )


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.button [ Html.Events.onClick <| RenderAs HtmlPlease ] [ Html.text "Html, Please" ]
        , Html.button [ Html.Events.onClick <| RenderAs StylePlease ] [ Html.text "Style, Please" ]
        , Html.div [] [ Html.text (toString model.count) ]
        , case model.renderAs of
            HtmlPlease ->
                Html.div []
                    [ staticStyleSheet
                    , Html.Lazy.lazy viewHtml 10000
                    ]

            StylePlease ->
                Element.layout []
                    (Element.Lazy.lazy viewStyle 10000)

            NothingPlease ->
                Html.text "Nothing rendered.."
        ]



-- on second render, js time goes down to single digit ms, small bit of updating layout, and updating layout tree.


viewHtml x =
    Html.div [ Html.Attributes.class "se column spacing-20-20 content-top height-fill width-fill" ]
        (List.repeat x (Html.div [ Html.Attributes.class "se el width-content height-content self-center-y self-center-x" ] [ Html.div [ Html.Attributes.class "se text width-fill" ] [ Html.text "hello!" ] ]))


viewStyle x =
    Element.column []
        (List.repeat x (Element.el [] (Element.text "hello!")))


staticStyleSheet =
    Html.node "style"
        []
        [ Html.text """
html {
  height: 100%;
}

body {
  height: 100%;
}

input {
  border: none;
}

a {
  text-decoration: none;
  color: inherit;
}

.style-elements {
  width: 100%;
  height: auto;
  min-height: 100%;
}

.se {
  position: relative;
  display: flex;
  flex-direction: row;
  box-sizing: border-box;
  margin: 0;
  padding: 0;
  border-width: 0;
  border-style: solid;
  font: inherit;
}

.se.above {
  position: absolute;
  display: block;
  top: 0;
  height: 0;
  z-index: 10;
}

.se.above > .height-fill {
  height: auto;
}

.se.below {
  position: absolute;
  display: block;
  bottom: 0;
  height: 0;
  z-index: 10;
}

.se.below > .height-fill {
  height: auto;
}

.se.bold {
  font-weight: 700;
}

.se.border-dashed {
  border-style: dashed;
}

.se.border-dotted {
  border-style: dotted;
}

.se.border-none {
  border-width: 0;
}

.se.border-solid {
  border-style: solid;
}

.se.italic {
  font-style: italic;
}

.se.on-left {
  position: absolute;
  display: block;
  right: 100%;
  width: 0;
  z-index: 10;
}

.se.on-right {
  position: absolute;
  display: block;
  left: 100%;
  width: 0;
  z-index: 10;
}

.se.overlay {
  position: absolute;
  display: block;
  left: 0;
  top: 0;
  z-index: 10;
}

.se.strike {
  text-decoration: line-through;
}

.se.text-center {
  text-align: center;
}

.se.text-justify {
  text-align: justify;
}

.se.text-justify-all {
  text-align: justify-all;
}

.se.text-left {
  text-align: left;
}

.se.text-light {
  font-weight: 300;
}

.se.text-right {
  text-align: right;
}

.se.underline {
  text-decoration: underline;
}

.se.width-content {
  width: auto;
}

.text {
  white-space: pre;
  display: inline-block;
}

.spacer + .se {
  margin-top: 0;
  margin-left: 0;
}

.el {
  display: flex;
  flex-direction: row;
}

.el > .height-fill {
  height: 100%;
}

.el > .se.self-bottom {
  align-self: flex-end;
}

.el > .se.self-center-x {
  margin-left: auto;
  margin-right: auto;
}

.el > .se.self-center-y {
  align-self: center;
}

.el > .se.self-left {
  margin-right: auto;
}

.el > .se.self-right {
  margin-left: auto;
}

.el > .se.self-top {
  align-self: flex-start;
}

.el > .width-fill {
  width: 100%;
}

.el.content-bottom {
  align-items: flex-end;
}

.el.content-center-x {
  justify-content: center;
}

.el.content-center-y {
  align-items: center;
}

.el.content-left {
  justify-content: flex-start;
}

.el.content-right {
  justify-content: flex-end;
}

.el.content-top {
  align-items: flex-start;
}

.nearby {
  position: absolute;
  width: 100%;
  height: 100%;
  pointer-events: none;
}

.row {
  display: flex;
  flex-direction: row;
}

.row > .height-fill {
  height: 100%;
}

.row > .se.self-bottom {
  align-self: flex-end;
}

.row > .se.self-center-y {
  align-self: center;
}

.row > .se.self-top {
  align-self: flex-start;
}

.row > .width-fill {
  flex-grow: 1;
}

.row.content-bottom {
  align-items: flex-end;
}

.row.content-center-x {
  justify-content: center;
}

.row.content-center-y {
  align-items: center;
}

.row.content-left {
  justify-content: flex-start;
}

.row.content-right {
  justify-content: flex-end;
}

.row.content-top {
  align-items: flex-start;
}

.row.space-evenly {
  justify-content: space-between;
}

.column {
  display: flex;
  flex-direction: column;
}

.column > .height-fill {
  flex-grow: 1;
}

.column > .se.self-center-x {
  align-self: center;
}

.column > .se.self-left {
  align-self: flex-start;
}

.column > .se.self-right {
  align-self: flex-end;
}

.column > .width-fill {
  width: 100%;
}

.column.content-bottom {
  justify-content: flex-end;
}

.column.content-center-x {
  align-items: center;
}

.column.content-center-y {
  justify-content: center;
}

.column.content-left {
  align-items: flex-start;
}

.column.content-right {
  align-items: flex-end;
}

.column.content-top {
  justify-content: flex-start;
}

.page {
  display: block;
}

.page > .se.self-left {
  float: left;
}

.page > .se.self-left:after: {
  content: "";
  display: table;
  clear: both;
}

.page > .se.self-left:first-child + .se {
  margin: 0 !important;
}

.page > .se.self-right {
  float: right;
}

.page > .se.self-right:after: {
  content: "";
  display: table;
  clear: both;
}

.page > .se.self-right:first-child + .se {
  margin: 0 !important;
}

.paragraph {
  display: block;
}

.paragraph > .column {
  display: inline-flex;
}

.paragraph > .el {
  display: inline-flex;
}

.paragraph > .el > .text {
  display: inline;
  white-space: normal;
}

.paragraph > .grid {
  display: inline-grid;
}

.paragraph > .row {
  display: inline-flex;
}

.paragraph > .se.self-left {
  float: left;
}

.paragraph > .se.self-right {
  float: right;
}

.paragraph > .text {
  display: inline;
  white-space: normal;
}

.hidden {
  display: none;
}

.bg-52-101-164-100{background-color:rgba(52,101,164,1)}
.text-color-255-255-255-100{color:rgba(255,255,255,1)}
.font-size-20{font-size:20px}
.font-opensansgeorgiaserif{font-family:"Open Sans", "georgia", serif}
""" ]
