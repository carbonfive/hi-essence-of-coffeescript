class EssenceOfCoffeeScript.CoffeeScriptEditor extends EssenceOfCoffeeScript.JavaScriptEditor

  javascriptSourceCode: => @compileCoffeeScript()
  compileCoffeeScript: => '' + CoffeeScript.compile @aceEditor.getValue(), bare: on