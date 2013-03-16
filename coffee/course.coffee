$ = $ || jQuery
window.EssenceOfCoffeeScript = window.EssenceOfCoffeeScript || {}

EssenceOfCoffeeScript.options = 
  fadeOutDuration: 200
  fadeInDuration: 400

log = (args...)->
  return console.log args... unless console._log
  console._log args...

class EssenceOfCoffeeScript.Course extends Backbone.View
  defaultSpot: '#course'
  elTemplate: '#course-template'

  events: # human interaction event
    'click .splash'            : 'hiStart'
    'click .outline li input'  : 'hiGoto'
#     'click .next'              : 'hiNext'
#     'click .back'              : 'hiBack'
#     'click .console'           : 'hiRun'
#     'keyup textarea'           : 'hiType'
#     'focus textarea'           : 'hiType'

  initialize: (attributes) =>
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options
    @model = @materializeModel $('markup course')
    @el = $(@elTemplate).htmlElement()
    @$el = $(@el)

    @$teaser = $('.teaser')
    @$splash = @$('.splash')
    @$title = @$splash.find('.title')
    @$outline = @$('.outline ol')
    @$factoid = @$('.factoid')
    @$givenCode = @$('#given-code')
    @$givenCodeEditor = @$('#given-code-editor')
    @$userCode = @$('#user-code')
    @$userCodeEditor = @$('#user-code-editor')
    @$javaScriptSyntax = @$('#js-syntax')
    @$javaScriptSyntaxEditor = @$('#js-syntax-editor')
    @$coffeeScriptSyntax = @$('#coffee-syntax')
    @$coffeeScriptSyntaxEditor = @$('#coffee-syntax-editor')
    @$exampleCode = @$('#example-code')
    @$exampleCodeEditor = @$('#example-code-editor')

    @jqconsoleSession = []

    @exercises = []
    @currentExercise = null
    @loadExercises()
    setTimeout @hijackConsole, 5000

  hijackConsole: ()=>
    window.console._log = console.log
    window.console.log = (args...)=>
      window.console._log args...
      @jqconsole.Write ''+arg+'\n' for arg in args
      undefined

  restoreConsole: ()=> 
    window.console.log = window.console._log if window.console._log?

  materializeModel: ($elModel)->
    atts =
      title: $elModel.textValue 'title'
    @model = new Backbone.Model atts

  renderAtt: (name) => 
    @["$#{name}"]?.html?(@model.get name)
  render: =>
    @renderAtt 'title'
    @

  renderInto: (@spot) =>
    @$spot = $(@spot)
    @$spot.append @render().el
    @launchEditors()
    @
  launchEditors: ()=>
    # ace.config.set("workerPath", "ace")
    @launchJavaScriptSyntaxEditor()
    @launchCoffeeScriptSyntaxEditor()
    @launchExampleCodeEditor()
    @launchGivenCodeEditor()
    @launchUserCodeEditor()
    @launchUserConsole()
    @

  launchJavaScriptSyntaxEditor: ()=>
    id = 'js-syntax-editor'
    theme = 'solarized_light'
    readOnlyMode = true
    @javaScriptSyntaxEditor = @launchEditor {id, theme, readOnlyMode}

  launchCoffeeScriptSyntaxEditor: ()=>
    id = 'coffee-syntax-editor'
    theme = 'solarized_light'
    readOnlyMode = true
    @coffeeScriptSyntaxEditor = @launchEditor {id, theme, readOnlyMode}

  launchExampleCodeEditor: ()=>
    id = 'example-code-editor'
    readOnlyMode = true
    @exampleCodeEditor = @launchEditor {id, readOnlyMode}

  launchGivenCodeEditor: ()=>
    id = 'given-code-editor'
    theme = 'solarized_light'
    readOnlyMode = true
    @givenCodeEditor = @launchEditor {id, theme, readOnlyMode}

  launchUserCodeEditor: ()=>
    evalUserCode = (event)=> @evaluateUserCode()
    @userCodeEditor = new EssenceOfCoffeeScript.Editor 
      el: '#user-code-editor'
      displaySettings: minHeight: 100
    @userCodeEditor.aceEditor.on 'change', (event)=> @evaluateUserCode()

  launchEditor: ({id, theme, readOnlyMode}, displayOptions)->
    readOnlyMode = readOnlyMode?
    theme = theme || 'solarized_dark'
    editor = ace.edit id
    editor.getSession().setMode('ace/mode/coffee')
    editor.setTheme 'ace/theme/' + theme
    editor.setReadOnly readOnlyMode
    $("##{id}").autoAdjustAceEditorHeight(editor, displayOptions)
    editor

  hideJavaScriptSyntax: ()=>
    @$javaScriptSyntax.fadeOut()

  showJavaScriptSyntax: (code)=>
    @javaScriptSyntaxEditor.setValue('')
    @javaScriptSyntaxEditor.insert(code)
    @$javaScriptSyntax.delay(100).fadeIn => @javaScriptSyntaxEditor.autoAdjustHeight()

  hideCoffeeScriptSyntax: ()=>
    @$coffeeScriptSyntax.fadeOut()

  showCoffeeScriptSyntax: (code)=>
    @coffeeScriptSyntaxEditor.setValue('')
    @coffeeScriptSyntaxEditor.insert(code)
    @$coffeeScriptSyntax.delay(100).fadeIn => @coffeeScriptSyntaxEditor.autoAdjustHeight()

  hideExampleCode: ()=>
    @$exampleCode.fadeOut()

  showExampleCode: (code)=>
    @exampleCodeEditor.setValue('')
    @exampleCodeEditor.insert(code)
    @$exampleCode.delay(100).fadeIn => @exampleCodeEditor.autoAdjustHeight()

  hideGivenCode: ()=>
    @$givenCode.fadeOut()

  showGivenCode: (code)=>
    @givenCodeEditor.setValue('')
    @givenCodeEditor.insert(code)
    @$givenCode.delay(100).fadeIn => @givenCodeEditor.autoAdjustHeight()

  hideUserCode: ()=>
    @$userCode.fadeOut()

  showUserCode: (code)=>
    @userCodeEditor.aceEditor.setValue('')
    @userCodeEditor.aceEditor.insert(code)
    @$userCode.delay(100).fadeIn => @userCodeEditor.aceEditor.autoAdjustHeight()

  launchUserConsole: ()->
    header = 'CoffeeScript Console\n'
    @jqconsole = $('#user-console').jqconsole(header, '>> ', '.. ');

    @jqconsole.RegisterShortcut 'A', => @jqconsole.MoveToStart(); @jqconsoleHandler()
    @jqconsole.RegisterShortcut 'E', => @jqconsole.MoveToEnd();@jqconsoleHandler()

    @jqconsole.RegisterMatching '{', '}', 'brace'
    @jqconsole.RegisterMatching '(', ')', 'paran'
    @jqconsole.RegisterMatching '[', ']', 'bracket'

    @jqconsoleHandler()

  jqconsoleHandler: (command)=>
    if command
      try
        result = @evaluateCode command 
        output = switch typeof result
          when 'function'
            '[Function]'
          when 'object'
            JSON.stringify result, null, 0
          when 'undefined'
            ''
          else 
            JSON.stringify result, null, 1
        @jqconsole.Write '' + output + '\n'
      catch e
        @jqconsole.Write 'ERROR: ' + e.message + '\n'
    @jqconsole.Prompt true, @jqconsoleHandler, (command)->
      # Continue line if can't compile the command.
      try
        compiledJS = '' + CoffeeScript.compile command, bare: on
        Function compiledJS 
      catch e
        return 1 if /[\[\{\(]$/.test command
        return 0
      return false

  evaluateUserCode: ()=>
    sourceCode = @userCodeEditor.aceEditor.getValue()
    return unless sourceCode?.length > 0
    try
      compiledJS = '' + CoffeeScript.compile sourceCode, bare: on
      Function compiledJS 
      @hideUserCodeCompilationError()
    catch e
      @userCodeCompilationError = e.message
      @showUserCodeCompilationError(e.message)
    # try
    #   # compiledJS = '' + CoffeeScript.compile sourceCode, bare: on
    #   # compiledJS = '' + CoffeeScript.eval sourceCode, bare: on#, sandbox: true
    #   result = @evaluateCode sourceCode
    #   console.log compiledJS
    # catch e
    #   console.log e.message


  hideUserCodeCompilationError: ()=>
    @$('#user-code-error').fadeOut => @$('#user-code-error').html('')

  showUserCodeCompilationError: (@userCodeCompilationErrorMessage)->
    @$('#user-code-error').html(@userCodeCompilationErrorMessage).fadeIn()

  evaluateCode: (sourceCode) =>
    compiledJS = '' + CoffeeScript.compile sourceCode, bare: on
    # compiledJS = '' + CoffeeScript.eval sourceCode, bare: on #, sandbox: true
    # compiledJS = '' + CoffeeScript.eval @userCodeEditor.getValue() + "\n" + sourceCode, bare: on #, sandbox: true
    @currentExercise.scope.run compiledJS

  findExercise: (idx) =>
    return null unless @exercises?
    return null unless 0 <= idx < @exercises.length
    @exercises[idx]

  start: ()=>
    return if @started?
    @started = true
    @startTimer = null
    @$splash.fadeOut @options.fadeOutDuration
    # @$teaser.slideUp 2000 if @$teaser.is ':visible'

  next: =>
    idx = if @currentExercise? then 1 + @currentExercise.idx else 0
    @displayExercise idx

  back: =>
    idx = @currentExercise?.idx || @exercises.length
    idx = -1 + idx
    @displayExercise idx

  loadExercises: () =>
    elExercise = @$('.exercise')
    for elModel, idx in $('markup exercise')
      $elModel = $(elModel)
      exerciseView = new EssenceOfCoffeeScript.Exercise { idx, $elModel, el: elExercise, course: @ }
      @exercises.push exerciseView

  displayExercise: (idx)=>
    exercise = @findExercise idx
    return unless exercise?
    @start() unless @started?

#     @clearEditor()
#     @$coder.fadeIn(fadeInDuration) unless @$coder.is ':visible'

    @currentExercise?.undisplay()
    @currentExercise = exercise
    @currentExercise?.display()

  hiStart:  (event) => @start(); @next()
  hiNext:   (event) => @next()
  hiBack:   (event) => @back()
  hiGoto:   (event) => @displayExercise( parseInt $(event.target).data('idx') ); event.preventDefault()
