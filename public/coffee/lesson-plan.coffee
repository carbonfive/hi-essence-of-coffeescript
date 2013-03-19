$ = jQuery

class EssenceOfCoffeeScript.LessonPlan extends Backbone.View

  initialize: (attributes) =>
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options

    { @$elLessonPlanModel, @course, @idx } = attributes

    @model = @materializeModel()

    @course.$lessonPlansNavbar.find('ol').append("<li><input class='show-lesson' type='submit' value='#{@idx}' data-idx='#{@idx}'/></li>")

    @$title = @course.$('data.title')
    @$navbar = $('<ol>')

    @exercises = []
    @loadExercises()
    @currentExercise = @exercises[0]

  materializeModel: ()->
    atts =
      title: @$elLessonPlanModel.textValue 'title'
    @model = new Backbone.Model atts

  render: =>
    @display()
    @


  findExercise: (idx) => @exercises[idx] if 0 <= idx < @exercises?.length    

  nextExercise: =>
    scrollTop = @course.$el.offset().top
    scrollTop = scrollTop - 10 if scrollTop > 10
    $('html, body').animate { scrollTop } , 1000

    idx = if @currentExercise? then 1 + @currentExercise.idx else 0
    if idx >= @exercises.length
      idx = @exercises.length - 1
      @course.nextLesson()
    else
      @displayExercise idx

  back: =>
    idx = @currentExercise?.idx || @exercises.length
    idx = -1 + idx
    @displayExercise idx

  loadExercises: () =>
    el = @course.$el.find('.exercise')
    for elExerciseModel, idx in @$elLessonPlanModel.find('data.exercise')
      $elExerciseModel = $(elExerciseModel)
      exerciseView = new EssenceOfCoffeeScript.Exercise { idx, $elExerciseModel, el, lessonPlan: @, course: @course }
      @exercises.push exerciseView

  displayExercise: (idx)=>
    exercise = @findExercise idx
    return unless exercise?
    @currentExercise = exercise
    @display()

  display: () =>
    @course.$exercisesNavbar.html @$navbar 
    @course.$lessonTitle.html @model.get 'title'
    @currentExercise.display()

  hiGotoExercise:   (event) => @displayExercise( parseInt $(event.target).data('idx') ); event.preventDefault()