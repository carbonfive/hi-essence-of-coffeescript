$ = jQuery

class EssenceOfCoffeeScript.LessonPlan extends Backbone.View

  initialize: (attributes) =>
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options

    { @$elLessonPlanModel, @course, @idx } = attributes

    @model = @materializeModel()

    @course.$outline.append("<li><input type='submit' value='#{@model.get 'title' }' data-idx='#{@idx}'/></li>")

    @$title = @course.$('.title')
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

  next: =>
    idx = if @currentExercise? then 1 + @currentExercise.idx else 0
    @displayExercise idx

  back: =>
    idx = @currentExercise?.idx || @exercises.length
    idx = -1 + idx
    @displayExercise idx

  loadExercises: () =>
    el = @course.$el.find('.exercise')
    for elExerciseModel, idx in @$elLessonPlanModel.find('exercise')
      $elExerciseModel = $(elExerciseModel)
      exerciseView = new EssenceOfCoffeeScript.Exercise { idx, $elExerciseModel, el, lessonPlan: @, course: @course }
      @exercises.push exerciseView

  displayExercise: (idx)=>
    exercise = @findExercise idx
    return unless exercise?
    @currentExercise = exercise
    # @undisplay()
    @display()

  display: (callback) =>
    @course.$lessonPlanNavbar.html @$navbar 
    @course.$title.html @model.get 'title'
    @currentExercise.display(callback)

  undisplay: (duration, callback) =>
    @currentExercise.undisplay(duration, callback)


  hiNext:   (event) => @next()
  hiBack:   (event) => @back()
  hiGotoExercise:   (event) => @displayExercise( parseInt $(event.target).data('idx') ); event.preventDefault()
