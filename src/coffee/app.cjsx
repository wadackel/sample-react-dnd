React           = require("react")
HTML5Backend    = require("react-dnd/modules/backends/HTML5")
DnD             = require("react-dnd")
DragDropContext = DnD.DragDropContext
DragSource      = DnD.DragSource
DropTarget      = DnD.DropTarget
classNames      = require("classNames")



# ドラッグ元のインターフェースを持たせる
itemSource = 
  beginDrag: (props) ->
    id: props.id

# ドラッグ元の機能と独自コンポーネントをつなぐ
collectSource = (connect, monitor) ->
  connectDragSource : connect.dragSource()
  connectDragPreview: connect.dragPreview()
  isDragging        : monitor.isDragging()

# ドラッグ先も同様にインターフェースとコンポーネントの結びつきを用意
itemTarget = 
  hover: (props, monitor) ->
    draggedId = monitor.getItem().id
    if draggedId != props.id
      props.moveItem(draggedId, props.id)
    return

collectTarget = (connect) ->
  connectDropTarget: connect.dropTarget()



# アイテムコンポーネント
Item = React.createClass(
  propTypes:
    connectDragSource : React.PropTypes.func.isRequired
    connectDragPreview: React.PropTypes.func.isRequired
    connectDropTarget : React.PropTypes.func.isRequired
    isDragging        : React.PropTypes.bool.isRequired
    id                : React.PropTypes.any.isRequired
    text              : React.PropTypes.string.isRequired
    moveItem          : React.PropTypes.func.isRequired

  render: ->
    classes = classNames(
      "list-group-item": true
      "dragging"       : @props.isDragging
    )

    # 全体のドラッグ操作を許す場合
    @props.connectDragSource(@props.connectDropTarget(
      <div className={classes}>
        <span className="list-group-item__handle"></span>{@props.text}
      </div>
    ))

    # # ハンドルのみのドラッグ操作の場合
    # @props.connectDragPreview(@props.connectDropTarget(
    #   <div className={classes}>
    #     {@props.connectDragSource(
    #       <span className="list-group-item__handle"></span>
    #     )}
    #     {@props.text}
    #   </div>
    # ))
)

# ドラッグ＆ドロップの機能を`Item`コンポーネントにかぶせる
Item = DropTarget("item", itemTarget, collectTarget)(Item)
Item = DragSource("item", itemSource, collectSource)(Item)



# Appコンポーネント (ルート)
App = React.createClass(
  getInitialState: ->
    items: [
      {id: 1, text: "I am item01"}
      {id: 2, text: "I am item02"}
      {id: 3, text: "I am item03"}
      {id: 4, text: "I am item04"}
      {id: 5, text: "I am item05"}
      {id: 6, text: "I am item06"}
    ]

  handleMoveItem: (id, afterId) ->
    items = @state.items.concat()

    item = (obj for obj in items when obj.id == id)[0]
    itemIndex = items.indexOf(item)

    afterItem = (obj for obj in items when obj.id == afterId)[0]
    afterItemIndex = items.indexOf(afterItem)

    items[itemIndex] = afterItem
    items[afterItemIndex] = item

    @setState(items: items)

  render: ->
    items = @state.items.map((item) =>
      <Item key={item.id}
            id={item.id}
            text={item.text}
            moveItem={@handleMoveItem} />
    )

    <div className="container">
      <h1>React.jsのドラッグ＆ドロップサンプル</h1>
      <div className="panel panel-default">
        <div className="panel-heading">
          <h2 className="panel-title">ドラッグ＆ドロップのリスト</h2>
        </div>
        <div className="panel-body">
          下記のリストアイテムはドラッグ可能です！
        </div>
        <ul className="list-group">
          {items}
        </ul>
      </div>
    </div>
)

# Appコンポーネントをドラッグ＆ドロップのコンテキストとする
App = DragDropContext(HTML5Backend)(App)



React.render(<App />, document.getElementById("app"))