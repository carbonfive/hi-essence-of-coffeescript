$ = jQuery

class EssenceOfCoffeeScript.Course extends Backbone.View
  defaultSpot: '#course'
  elTemplate: '#course-template'

  events: # human interaction event
    'click .splash'            : 'hiStart'
    'click .navbar .show-lesson'  : 'hiGotoLesson'
    'click .navbar .show-exercise'  : 'hiGotoExercise'
#     'click .next'              : 'hiNext'
#     'click .back'              : 'hiBack'

  initialize: (attributes) =>
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options
    @model = @materializeModel $('markup course')
    @el = $(@elTemplate).htmlElement()
    @$el = $(@el)

    @$teaser = $('.teaser')
    @$splash = @$('.splash')
    @$title = @$splash.find('.title')
    @$lessonPlansNavbar = @$('.navbar .lessonplans')
    console.log 'less nav', @$lessonPlansNavbar
    @$factoid = @$('.factoid')

    @$exercisesNavbar = @$('.navbar .lessonplans .exercises')
    @lessonPlans = []
    @currentLesson = null
    @loadLessonPlans()
    setTimeout @hijackConsole, 5000

  hijackConsole: ()=>
    window.console._log = console.log
    window.console.log = (args...)=>
      window.console._log args...
      @jqconsole.Write?(''+arg+'\n') for arg in args
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

  launchUserConsole: ()=>
    @jqconsole = new EssenceOfCoffeeScript.Console
      el: '#user-console'
    @jqconsole.addCodeEditor @userCodeEditor, @givenCodeEditor

  hideUserCodeParseError: ()=>
    @$('#user-code-error').fadeOut => @$('#user-code-error').html('')

  showUserCodeParseError: (@userCodeCompilationErrorMessage)=>
    @$('#user-code-error').html(@userCodeCompilationErrorMessage).fadeIn()

  findLessonPlan: (idx) => @lessonPlans[idx] if 0 <= idx < @lessonPlans?.length

  start: ()=>
    return if @started?
    @started = true
    @startTimer = null
    @$splash.fadeOut @options.fadeOutDuration
    # @$teaser.slideUp 2000 if @$teaser.is ':visible'

  next: =>
    idx = if @currentLessonPlan? then 1 + @currentLessonPlan.idx else 0
    @displayLessonPlan idx

  back: =>
    idx = @currentLessonPlan?.idx || @exercises.length
    idx = -1 + idx
    @displayExercise idx

  loadLessonPlans: () =>
    el = @$('.lessonplan')
    for elLessonPlanModel, idx in $('markup lessonplan')
      $elLessonPlanModel = $(elLessonPlanModel)
      lessonPlanView = new EssenceOfCoffeeScript.LessonPlan { idx, $elLessonPlanModel, el, course: @ }
      @lessonPlans.push lessonPlanView

  displayLessonPlan: (idx)=>
    lesson = @findLessonPlan idx
    return unless lesson?
    @start() unless @started?
 
    @currentLessonPlan?.undisplay()
    @currentLessonPlan = lesson
    @currentLessonPlan.display()

  hiStart:  (event) => @start(); @next()
  hiNext:   (event) => @next()
  hiBack:   (event) => @back()
  hiGotoLesson:   (event) => @displayLessonPlan( parseInt $(event.target).data('idx') ); event.preventDefault()
  hiGotoExercise:   (event) => @currentLessonPlan.hiGotoExercise(event)