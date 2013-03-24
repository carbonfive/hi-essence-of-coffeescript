class EssenceOfCoffeeScript.JavaScriptEditor extends EssenceOfCoffeeScript.Editor

  initialize: (attributes) =>
    super attributes
    { @onParse, @onParseException } = attributes

    @evaluated = false
    @parseException = null

    if @onParse?
      @aceEditor.on 'change', (event)=> 
        @evaluated = false
        @parseCode()

  parseCode: =>
    @parseException = null
    try
      Function @javascriptSourceCode()
      @onParse?()
    catch e
      @parseException = e
      @onParseException?(e.message)

  runCode: =>
    return if @evaluated
    eval.call window, @javascriptSourceCode()
    @evaluated = true

  javascriptSourceCode: => @aceEditor.getValue()