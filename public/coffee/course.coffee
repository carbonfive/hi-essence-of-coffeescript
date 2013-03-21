$ = jQuery

class EssenceOfCoffeeScript.Course extends Backbone.View
  defaultSpot: '#course'
  elTemplate: '#course-template'

  events: # human interaction event
    'click .next-exercise'  : 'hiNext'
    'click .show-lesson'    : 'hiGotoLesson'
    'click .show-exercise'  : 'hiGotoExercise'

  initialize: (attributes)=>
    super attributes
    { @elSpot } = attributes
    @$elSpot = $(@elSpot)

    _.extend @options, EssenceOfCoffeeScript.options
    @model = @materializeModel $('data.markup data.course')
    @el = $(@elTemplate).htmlElement()
    @$el = $(@el)
    @$content = @$('.course-content')
    @$exercise = @$('.course-content .exercise')

    @$lessonTitle = @$('.lesson-title')

    @$lessonPlansNavbar = @$('.lesson-navbar')
    @$lessonPlansNavbarTitle = @$('.navbar .lessonplans')

    @$exercisesNavbar = @$('.exercise-navbar')
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

  materializeModel: ($elModel)=>
    atts =
      title: $elModel.textValue 'title'
    @model = new Backbone.Model atts

  loadLessonPlans: ()=>
    el = @$('.lessonplan')
    for elLessonPlanModel, idx in $('data.markup data.lessonplan')
      $elLessonPlanModel = $(elLessonPlanModel)
      lessonPlanView = new EssenceOfCoffeeScript.LessonPlan { idx, $elLessonPlanModel, el, course: @ }
      @lessonPlans.push lessonPlanView
    @currentLessonPlan = @lessonPlans[0]

  renderAtt: (name)=> 
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

  activate: (activateFunctor)=>
    @$('.show-lesson').removeClass('active')
    @$('.show-exercise').removeClass('active')    
    @deactivateContent()
    # @scrollToTop()
    setTimeout activateFunctor, 200
    setTimeout @activateContent, 800

  scrollToTop: ()=> $('html, body').animate {scrollTop: @$el.offset().top - 10}
  activateContent: ()=> @$content.removeClass('deactivated')
  deactivateContent: ()=> @$content.addClass('deactivated')

  next: ()=>
    if @started
      @currentLessonPlan.activateNextExercise()
    else 
      @activateLessonPlan(0)

  activateNextLesson: ()=>
    idx = if @currentLessonPlan? then 1 + @currentLessonPlan.idx else 0
    idx = @lessonPlans.length - 1 if idx > @lessonPlans.length
    @activateLessonPlan idx

  activateLessonPlan: (idx)=>
    @started = true
    @currentLessonPlan = @findLessonPlan(idx)?.activate() || @currentLessonPlan.activate()

  hiNext: (event)=>
    event.preventDefault()
    @activate ()=> @next()

  hiGotoLesson: (event)=>
    event.preventDefault()
    @activate ()=> @activateLessonPlan( parseInt $(event.target).data('idx') )

  hiGotoExercise: (event)=>
    event.preventDefault()
    @activate ()=> @currentLessonPlan.hiGotoExercise(event)
