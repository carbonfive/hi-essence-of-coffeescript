$ = jQuery

class EssenceOfCoffeeScript.Course extends Backbone.View
  defaultSpot: '#course'
  elTemplate: '#course-template'

  events: # human interaction event
    'click .next-exercise'          : 'hiNext'
    'click .navbar .show-lesson'    : 'hiGotoLesson'
    'click .navbar .show-exercise'  : 'hiGotoExercise'

  initialize: (attributes) =>
    super attributes
    { @elSpot } = attributes
    @$elSpot = $(@elSpot)

    _.extend @options, EssenceOfCoffeeScript.options
    @model = @materializeModel $('data.markup data.course')
    @el = $(@elTemplate).htmlElement()
    @$el = $(@el)
    @$exercise = @$('.course-content .exercise')

    @$lessonTitle = @$('.lesson-title')

    @$lessonPlansNavbar = @$('.navbar .lessonplans')
    @$lessonPlansNavbarTitle = @$('.navbar .lessonplans')
    @$factoid = @$('.factoid')

    @$exercisesNavbar = @$('.navbar .exercises')
    @lessonPlans = []
    @loadLessonPlans()

    setTimeout @hijackConsole, 5000

    @render()


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
    @$elSpot.append @el
    @launchEditors()
    @launchUserConsole()
    @start() # load the first lesson and exercise
    @

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

  start: ()=> @next() unless @started

  next: ()=>
    if @started
      @currentLessonPlan?.nextExercise()
    else 
      @displayLessonPlan(0)

  nextLesson: ()=>
    idx = if @currentLessonPlan? then 1 + @currentLessonPlan.idx else 0
    idx = @lessonPlans.length - 1 if idx > @lessonPlans.length
    @displayLessonPlan idx

  loadLessonPlans: () =>
    el = @$('.lessonplan')
    for elLessonPlanModel, idx in $('data.markup data.lessonplan')
      $elLessonPlanModel = $(elLessonPlanModel)
      lessonPlanView = new EssenceOfCoffeeScript.LessonPlan { idx, $elLessonPlanModel, el, course: @ }
      @lessonPlans.push lessonPlanView
    @currentLessonPlan = @lessonPlans[0]

  displayLessonPlan: (idx)=>
    @started = true
    lesson = @findLessonPlan idx
    return unless lesson?
 
    # @currentLessonPlan?.undisplay ->lesson.display()
    @currentLessonPlan = lesson
    @currentLessonPlan.display()

  hiNext:   (event) => @next()
  hiGotoLesson:   (event) => @displayLessonPlan( parseInt $(event.target).data('idx') ); event.preventDefault()
  hiGotoExercise:   (event) => @currentLessonPlan.hiGotoExercise(event)