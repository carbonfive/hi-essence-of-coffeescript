$ = $ || jQuery

class EssenceOfCoffeeScript.Exercise extends Backbone.View
  elTemplate: '#exercise-template'

  events:
    'click .run-users-hack': 'hiRunUsersHack'

  hiRunUsersHack: (event)-> 
    try
      hackOutput = @userCodeEditor.runCode force:true
      @jqconsole.Write hackOutput if hackOutput?
    catch e
      @jqconsole.Write 'ERROR: ' + e.message + '\n'

  initialize: (attributes)=>
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options

    @el = $(@elTemplate).clone().htmlElement()
    @$el = $(@el)

    { @$elExerciseModel, @course, @lessonPlan, @idx } = attributes
    @materializeModel @$elExerciseModel
    @$title = @$('.title')
    @$headline = @$('.headline')
    @$realization = @course.$('.realization')
    @$description = @$('.description')
    @$instructions= @$('.instructions')
    @$instructionList= @$('.instructions ol')

    navbarLi =  $("<li></li>")
    @$navbarButton = $("<input class='show-exercise' type='submit' value='#{@idx + 1}' data-idx='#{@idx}'/>")
    navbarLi.append(@$navbarButton)
    navbarLi.append(" " + @model.get 'realization')
    @lessonPlan.$navbar.append navbarLi
    @$navbarButton = @lessonPlan.$navbar.find("li input[data-idx=#{@idx}]")
    @launchEditors()
    @launchUserConsole()
    @deactivate()


  materializeModel: (@$elExerciseModel)=>
    atts = @$elExerciseModel.pickHTMLValues 'title',
      'headline',
      'description',
      'realization',
      'instruction',
      'user-console',

    codeAtts = @$elExerciseModel.pickTextValues 'js-syntax',
      'coffee-syntax',
      'example-code',
      'given-code',
      'user-code'

    codeAtts[key] = @trimLinesOfCode(code) for key, code of codeAtts

    userCode = codeAtts['user-code']
    if userCode?
      codeAtts['user-code'] = '' if 'yes' is userCode.toLowerCase() or 'true' is userCode.toLowerCase()

    atts = _.extend atts, codeAtts
    atts.instruction = [atts.instruction] if 'string' is typeof atts.instruction
    @model = new Backbone.Model atts

  trimLinesOfCode: (sourceCode)-> sourceCode?.trim()

  activate: ()=>
    $html = $('html, body')

    @$headline.html @model.get 'headline'
    @$realization.html @model.get 'realization'
    @$description.html @model.get 'description'
    @$instructionList.html ''
    if @model.get('instruction')?.length > 0
      for instruction in @model.get 'instruction' 
        @$instructionList.append "<li class='instruction'>#{instruction}</li>"
    else 
      @$instructions.hide()

    @$realization.hide() unless @model.get('realization')?
    @$description.hide() unless @model.get('description')?

    @course.$content.html(@el)
    @$el.show()

    @renderEditor @javaScriptSyntaxEditor, @model.get('js-syntax')
    @renderEditor @coffeeScriptSyntaxEditor, @model.get('coffee-syntax')
    @renderEditor @exampleCodeEditor, @model.get('example-code')
    @renderEditor @givenCodeEditor, @model.get('given-code')
    @renderEditor @userCodeEditor, (@model.get('user-code') || ''), force:true
    @jqconsole.activate()

    @lessonPlan.$navbarButton.addClass('active')
    @$navbarButton.addClass('active')
    @

  renderEditor: (editor, code, options)-> 
    if code? or options?.force then editor?.show(code) else editor?.hide()

  deactivate: ()=>
    @$el.hide()
    @jqconsole.deactivate()
    @$navbarButton.removeClass('active')

  launchEditors: ()=>
    ace.config.set("workerPath", "http://essence-of-coffeescript.herokuapp.com/js/vendor/ace")
    @launchJavaScriptSyntaxEditor()
    @launchCoffeeScriptSyntaxEditor()
    @launchExampleCodeEditor()
    @launchGivenCodeEditor()
    @launchUserCodeEditor()
    @

  launchJavaScriptSyntaxEditor: ()=>
    @javaScriptSyntaxEditor = new EssenceOfCoffeeScript.JavaScriptEditor 
      el: @.$('.js-syntax-editor')
      widgetEl: @.$('.js-syntax')
      options:
        theme: 'solarized_light'
        readOnlyMode: true

  launchCoffeeScriptSyntaxEditor: ()=>
    @coffeeScriptSyntaxEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: @.$ '.coffee-syntax-editor'
      widgetEl: @.$ '.coffee-syntax'
      options:
        theme: 'solarized_light'
        readOnlyMode: true

  launchExampleCodeEditor: ()=>
    @exampleCodeEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: @.$ '.example-code-editor'
      widgetEl: @.$ '.example-code'
      options:
        theme: 'solarized_light'
        readOnlyMode: true

  launchGivenCodeEditor: ()=>
    @givenCodeEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: @.$ '.given-code-editor'
      widgetEl: @.$ '.given-code'
      options:
        readOnlyMode: true

  launchUserCodeEditor: ()=>
    @userCodeEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: @.$ '.user-code-editor'
      widgetEl: @.$ '.user-code'
      displaySettings: minHeight: 100
      autoParse: true

  launchUserConsole: ()=>
    @jqconsole = new EssenceOfCoffeeScript.Console
      el: @$ '.user-console'  
    @jqconsole.addCodeEditor @userCodeEditor, @givenCodeEditor
