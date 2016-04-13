{Range} = require 'atom'
_ = require 'underscore-plus'

getView = (model) ->
  atom.views.getView(model)

getVisibleBufferRange = (editor) ->
  # console.log editor
  [startRow, endRow] = getView(editor).getVisibleRowRange()
  return null unless (startRow? and endRow?)
  startRow = editor.bufferRowForScreenRow(startRow)
  endRow = editor.bufferRowForScreenRow(endRow)
  new Range([startRow, 0], [endRow, Infinity])

getRangesForText = (editor, text) ->
  ranges = []
  pattern = ///#{_.escapeRegExp(text)}///ig
  scanRange = getVisibleBufferRange(editor)
  editor.scanInBufferRange pattern, scanRange, ({range}) ->
    ranges.push(range)
  ranges

markerOptions = {invalidate: 'never', persistent: false}
decorateOptions = {type: 'highlight', class: 'smalls-candidate'}
decorateRanges = (editor, ranges) ->
  markers = []
  for range in ranges ? []
    marker = editor.markScreenRange(range, markerOptions)
    editor.decorateMarker(marker, decorateOptions)
    markers.push(marker)
  markers

getVisibleEditors = ->
  atom.workspace.getPanes()
    .map (pane) -> pane.getActiveEditor()
    .filter (editor) -> editor?

ElementBuilder =
  includeInto: (target) ->
    for name, value of this when name isnt "includeInto"
      target::[name] = value.bind(this)

  div: (params) ->
    @createElement 'div', params

  span: (params) ->
    @createElement 'span', params

  atomTextEditor: (params) ->
    @createElement 'atom-text-editor', params

  createElement: (element, {classList, textContent, id, attribute}) ->
    element = document.createElement element

    element.id = id if id?
    element.classList.add classList... if classList?
    element.textContent = textContent if textContent?
    for name, value of attribute ? {}
      element.setAttribute(name, value)
    element

module.exports = {
  getView
  getRangesForText
  decorateRanges
  ElementBuilder
  getVisibleBufferRange
  getVisibleEditors
}