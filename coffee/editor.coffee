###
# This class wraps an AceEditor.
# You can get one with:
# <script src="http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
###

$ = $ || jQuery
window.EssenceOfCoffeeScript = window.EssenceOfCoffeeScript || {}

class EssenceOfCoffeeScript.Editor extends Backbone.View

  defaultOptions:
    readOnlyMode: false
    languageMode: 'coffee'
    theme: 'solarized_dark'

  initialize: (attributes) =>
    super attributes
    return console.error attributes, 'Element Not Found', attributes.el unless @$el.exists()
    {options, events, displaySettings} = attributes

    @aceEditor = @launch options, displaySettings

    @$el.autoAdjustAceEditorHeight(@aceEditor, displaySettings)

  launch: (options, displaySettings)->
    opts = _.extend {}, @defaultOptions, options
    {theme, readOnlyMode, languageMode} = opts
    @aceEditor = ace.edit @el
    @aceEditor.getSession().setMode('ace/mode/' + languageMode)
    @aceEditor.setTheme 'ace/theme/' + theme
    @aceEditor.setReadOnly readOnlyMode
    @aceEditor
