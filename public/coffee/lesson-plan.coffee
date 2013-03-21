$ = jQuery

class EssenceOfCoffeeScript.LessonPlan extends Backbone.View

  initialize: (attributes)=>
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options

    { @$elLessonPlanModel, @course, @idx } = attributes

    @model = @materializeModel()

    @$navbarButton = $("<input class='show-lesson' type='submit' value='#{@idx + 1}' data-idx='#{@idx}'/>")
    @course.$lessonPlansNavbar.find('ol').append($("<li></li>").append(@$navbarButton))

    @$navbar = $('<ol>')

    @exercises = []
    @loadExercises()
    @currentExercise = @exercises[0]

  materializeModel: ()=>
    atts =
      title: @$elLessonPlanModel.textValue 'title'
      headline: @$elLessonPlanModel.textValue 'headline'
    @model = new Backbone.Model atts

  findExercise: (idx)=> @exercises[idx] if 0 <= idx < @exercises?.length    

  activateNextExercise: ()=>
    idx = if @currentExercise? then 1 + @currentExercise.idx else 0
    if idx >= @exercises.length
      idx = @exercises.length - 1
      @course.activateNextLesson()
    else
      @activateExercise idx

  back: ()=>
    idx = @currentExercise?.idx || @exercises.length
    idx = -1 + idx
    @displayExercise idx

  loadExercises: ()=>
    el = @course.$el.find('.exercise')
    for elExerciseModel, idx in @$elLessonPlanModel.find('data.exercise')
      $elExerciseModel = $(elExerciseModel)
      exerciseView = new EssenceOfCoffeeScript.Exercise { idx, $elExerciseModel, el, lessonPlan: @, course: @course }
      @exercises.push exerciseView

  activate: ()=>
    @course.$exercisesNavbar.html @$navbar 
    @course.$lessonTitle.html @model.get 'title'
    @currentExercise.activate()
    @

  deactivate: (callback)=> 
    @currentExercise.deactivate()
    # slide navbar off

  activateExercise: (idx)=> @currentExercise = @findExercise(idx)?.activate() || @currentExercise.activate()

  hiGotoExercise: (event)=> event.preventDefault(); @activateExercise( parseInt $(event.target).data('idx') )