###
# This class wraps an AceEditor.
# You can get one with:
# <script src="http://d1n0x3qji82z53.cloudfront.net/src-min-noconflict/ace.js" type="text/javascript" charset="utf-8"></script>
###

$ = $ || jQuery
window.EssenceOfCoffeeScript = window.EssenceOfCoffeeScript || {}

class EssenceOfCoffeeScript.Editor extends Backbone.View

  defaultOptions:
    autoCompile: false
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

class EssenceOfCoffeeScript.CoffeeScriptEditor extends EssenceOfCoffeeScript.Editor

  initialize: (attributes) =>
    super attributes
    { @onParse, @onParseException } = attributes
    console.log 'onpaarse', @onParse
    console.log attributes

    @compiledJavaScript = null
    @parseException = null
    @evaluated = false

    if @onParse?
      @aceEditor.on 'change', (event)=> @parseCode()

  compile: ()=> @compiledJavaScript = '' + CoffeeScript.compile @aceEditor.getValue(), bare: on

  parseCode: =>
    @evaluated = false
    @parseException = null
    try
      Function @compile()
      @onParse?()
    catch e
      @parseException = e
      @onParseException?(e.message)

  runCode: => eval.call window, @compile()
