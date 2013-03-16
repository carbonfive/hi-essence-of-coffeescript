class EssenceOfCoffeeScript.JavaScriptEditor extends EssenceOfCoffeeScript.Editor

  initialize: (attributes) =>
    super attributes
    @evaluated = false

  runCode: => 
    eval.call window, @compile()
    @evaluated = true
