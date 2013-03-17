$ = jQuery

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
    @javaScriptSyntaxEditor = new EssenceOfCoffeeScript.JavaScriptEditor 
      el: '#js-syntax-editor'
      widgetEl: '#js-syntax'
      options:
        theme: 'solarized_light'
        readOnlyMode: true

  launchCoffeeScriptSyntaxEditor: ()=>
    @coffeeScriptSyntaxEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: '#coffee-syntax-editor'
      widgetEl: '#coffee-syntax'
      options:
        theme: 'solarized_light'
        readOnlyMode: true

  launchExampleCodeEditor: ()=>
    @exampleCodeEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: '#example-code-editor'
      widgetEl: '#example-code'
      options:
        readOnlyMode: true

  launchGivenCodeEditor: ()=>
    @givenCodeEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: '#given-code-editor'
      widgetEl: '#given-code'
      options:
        readOnlyMode: true

  launchUserCodeEditor: ()=>
    @userCodeEditor = new EssenceOfCoffeeScript.CoffeeScriptEditor 
      el: '#user-code-editor'
      widgetEl: '#user-code'
      displaySettings: minHeight: 100
      onParse: @hideUserCodeParseError
      onParseException: @showUserCodeParseError

  launchUserConsole: ()->
    @jqconsole = new EssenceOfCoffeeScript.Console
      el: '#user-console'
    @jqconsole.addCodeEditor @userCodeEditor, @givenCodeEditor

  hideUserCodeParseError: ()=>
    @$('#user-code-error').fadeOut => @$('#user-code-error').html('')

  showUserCodeParseError: (@userCodeCompilationErrorMessage)=>
    @$('#user-code-error').html(@userCodeCompilationErrorMessage).fadeIn()

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
 
    @currentExercise?.undisplay()
    @currentExercise = exercise
    @currentExercise.display()

  hiStart:  (event) => @start(); @next()
  hiNext:   (event) => @next()
  hiBack:   (event) => @back()
  hiGoto:   (event) => @displayExercise( parseInt $(event.target).data('idx') ); event.preventDefault()
