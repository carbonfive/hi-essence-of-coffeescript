###
# This class wraps an AceEditor.
# You can get one with:
# <script src="http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
###

$ = $ || jQuery

class EssenceOfCoffeeScript.Editor extends Backbone.View

  defaultOptions:
    autoCompile: false
    readOnlyMode: false
    languageMode: 'coffee'
    theme: 'solarized_dark'

  initialize: (attributes) =>
    super attributes
    return console.error attributes, 'Element Not Found', attributes.el unless @$el.exists()
    {widgetEl, options, events, displaySettings} = attributes
    widgetEl = widgetEl || @el

    @$widgetEl = $(widgetEl)
    widgetEl = @$widgetEl[0]

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

  hide: ()=>
    console.log 'hide', @$widgetEl
    @$widgetEl.fadeOut()

  show: (code)=>
    console.log 'show', @$widgetEl
    @aceEditor.setValue('')
    @aceEditor.insert(code)
    @$widgetEl.delay(100).fadeIn => @aceEditor.autoAdjustHeight()
