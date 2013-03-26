class EssenceOfCoffeeScript.JavaScriptEditor extends EssenceOfCoffeeScript.Editor

  initialize: (attributes) =>
    super attributes


    @evaluated = false
    @timer2IndicateParseError = undefined

    @clearParseError()
    if true is attributes.autoParse
      @aceEditor.on 'change', (event)=> 
        @evaluated = false
        @parseCode()
        @timer2IndicateParseError = setTimeout(@showParseWarning, 1800) if @parseError.line?

  parseCode: =>
    try
      Function @javascriptSourceCode()
      @clearParseError()
      @onParse?()
    catch e
      @captureParseError (e)
      @onParseException?(e.message)

  runCode: =>
    return if @evaluated
    @parseCode()
    clearTimeout(@timer2IndicateParseError) if @timer2IndicateParseError?
    @clearAllAnnotations()
    @showParseError() if @parseErrorExists()
    eval.call window, @javascriptSourceCode()
    @evaluated = true

  clearParseError: ()=>
    @parseError =
      line: undefined
      message: undefined
      parseException: undefined
    @clearAllAnnotations()
    clearTimeout(@timer2IndicateParseError) if @timer2IndicateParseError?

  captureParseError: (ex)=>
    @parseError.parseException = ex

    [line, errorMessage] = ex.message.split ':'
    errorMessage ?= ex.message

    line ?= ''
    errorLine = (line.match /line (\d*)/)?[1]
    lineNumber =  parseInt errorLine if errorLine
    lineNumber ?= 1

    @parseError.line = lineNumber
    @parseError.message = errorMessage

  parseErrorExists: ()=> @parseError?.line?

  showParseWarning: ()=>
    return unless @parseErrorExists()
    @showWarning @parseError.line, @parseError.message

  showParseError: ()=>
    return unless @parseErrorExists()
    @showError @parseError.line, @parseError.message

  javascriptSourceCode: => @aceEditor.getValue()