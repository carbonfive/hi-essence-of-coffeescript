$ = $ || jQuery

class EssenceOfCoffeeScript.Exercise extends Backbone.View
  initialize: (attributes)->
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options

    { @$elExerciseModel, @course, @lessonPlan, @idx } = attributes
    @materializeModel @$elExerciseModel
    @$title = @$('.title')
    @$headline = @$('.headline')
    @$lesson = @$('.lesson')
    @$description = @$('.description')
    @$instructions= @$('.instructions')
    @$instructionList= @$('.instructions ol')

    @quote = @$('quote').text().trim()

    @lessonPlan.$navbar.append("<li><input class='show-exercise' type='submit' value='#{@idx}' data-idx='#{@idx}'/></li>")
    @$navbarButton = @lessonPlan.$navbar.find("li input[data-idx=#{@idx}]")

    @undisplay()

  materializeModel: (@$elExerciseModel)->
    atts = @$elExerciseModel.pickHTMLValues 'title',
      'headline',
      'description',
      'lesson',
      'instruction',
      'user-console',
      'factoid'
    codeAtts = @$elExerciseModel.pickTextValues 'js-syntax',
      'coffee-syntax',
      'example-code',
      'given-code',
      'user-code',
      'user-console',
    atts = _.extend atts, codeAtts
    atts.instruction = [atts.instruction] if 'string' is typeof atts.instruction
    @model = new Backbone.Model atts

  display: () =>
    @$headline.html @model.get 'headline'
    @$lesson.html @model.get 'lesson'
    @$description.html @model.get 'description'
    @$instructionList.html ''
    if @model.get('instruction')?.length > 0
      for instruction in @model.get 'instruction' 
        @$instructionList.append "<li class='instruction'>#{instruction}</li>"
      @$instructions.fadeIn()

    @$lesson.fadeOut() unless @model.get('lesson')?
    @$description.fadeOut() unless @model.get('description')?
    @$instructions.fadeOut() unless @model.get('instruction')?.length > 0

    @course.javaScriptSyntaxEditor.hide()
    @course.coffeeScriptSyntaxEditor.hide()
    @course.exampleCodeEditor.hide()
    @course.givenCodeEditor.hide()
    @course.userCodeEditor.hide()

    @course.javaScriptSyntaxEditor.show @model.get 'js-syntax' if @model.get('js-syntax')?
    @course.coffeeScriptSyntaxEditor.show @model.get 'coffee-syntax' if @model.get('coffee-syntax')?
    @course.exampleCodeEditor.show @model.get 'example-code' if @model.get('example-code')?
    @course.givenCodeEditor.show @model.get 'given-code' if @model.get('given-code')?.length > 0
    @course.userCodeEditor.show('') if @model.get('user-code')?
    
    @$el.delay(@options.fadeOutDuration + 10).fadeIn(@options.fadeInDuration)
    @$navbarButton.parents('ol').children('.active').removeClass('active')
    @$navbarButton.addClass('active')

  undisplay: (duration, callback) =>
    @$el.fadeOut @options.fadeOutDuration, callback
    @$navbarButton.removeClass('active')
