class EssenceOfCoffeeScript.CoffeeScriptEditor extends EssenceOfCoffeeScript.JavaScriptEditor

  initialize: (attributes) =>
    super attributes
    { @onParse, @onParseException } = attributes
    console.log 'onpaarse', @onParse
    console.log attributes

    @compiledJavaScript = null
    @parseException = null

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
