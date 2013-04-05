$ = jQuery

class EssenceOfCoffeeScript.Course extends Backbone.View
  defaultSpot: '#course'
  elTemplate: '#course-template'

  events: # human interaction event
    'click .next'             : 'hiNext'
    'mouseenter .show-lesson' : 'hiPreviewLesson'
    'mouseleave .show-lesson' : 'hiQuitPreviewLesson'
    'click .show-lesson'      : 'hiGotoLesson'
    'click .show-exercise'    : 'hiGotoExercise'

  initialize: (attributes)=>
    super attributes
    { @elSpot } = attributes
    @$elSpot = $(@elSpot)

    _.extend @options, EssenceOfCoffeeScript.options
    @model = @materializeModel $('data.markup data.course')
    @el = $(@elTemplate).htmlElement()
    @$el = $(@el)
    @$content = @$('.exercise-spot')
    @$exercise = @$('.exercise-spot .exercise')

    @$lessonTitle = @$('h2.lesson')

    @$lessonPlansNavbar = @$('nav.lesson')

    @$exercisesNavbar = @$('nav.exercise')
    @lessonPlans = []
    @loadLessonPlans()
    setTimeout @monitorConsole, 5000

    @render()

  monitorConsole: ()=>
    window.console._log = window.console._log || window.console.log
    window.console.log = (args...)->
      window.console._log args...
      $('html').trigger('log', { args } )
      undefined

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
    @start() # load the first lesson and exercise
    @

  findLessonPlan: (idx) => @lessonPlans[idx] if 0 <= idx < @lessonPlans?.length

  start: ()=> @next() unless @started

  activate: (activateFunctor)=>
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
    @$('.show-lesson').removeClass('active') unless @lessonPlans[idx] is @currentLessonPlan
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

  hiPreviewLesson: (event)=>
    event.preventDefault()
    idx =  parseInt $(event.target).data('idx')
    @$lessonTitle.html "<span class='preview'>#{@findLessonPlan(idx)?.title}</span>"

  hiQuitPreviewLesson: (event)=>
    event.preventDefault()
    @$lessonTitle.html @currentLessonPlan.title