class EssenceOfCoffeeScript.JavaScriptEditor extends EssenceOfCoffeeScript.Editor

  initialize: (attributes) =>
    super attributes
    { @onParse, @onParseException } = attributes

    @evaluated = false
    @parseException = null

    if @onParse?
      @aceEditor.on 'change', (event)=> @parseCode()

  parseCode: =>
    @evaluated = false
    @parseException = null
    try
      Function @javascriptSourceCode()
      @onParse?()
    catch e
      @parseException = e
      @onParseException?(e.message)

  runCode: =>
    eval.call window, @javascriptSourceCode()
    @evaluated = true

  javascriptSourceCode: => @aceEditor.getValue()