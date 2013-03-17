$ = $ || jQuery

log = (args...)->
  return console.log args... unless console._log
  console._log args...

class EssenceOfCoffeeScript.SourceCodeScope
  run: (jsCode)=> eval.call window, jsCode 

class EssenceOfCoffeeScript.Exercise extends Backbone.View
  initialize: (attributes)->
    super attributes
    _.extend @options, EssenceOfCoffeeScript.options

    { $elModel, @course, @idx } = attributes
    @materializeModel $elModel
    @resetScope()

    @$title = @$('.title')
    @$headline = @$('.headline')
    @$lesson = @$('.lesson')
    @$description = @$('.description')
    @$instructions= @$('.instructions')
    @$instructionList= @$('.instructions ol')

    @quote = @$('quote').text().trim()
    @course.$outline.append("<li><input type='submit' value='#{@model.get 'title' }' data-idx='#{@idx}'/></li>")
    @$outline = @course.$outline.find("li input[data-idx=#{@idx}]")

    @undisplay()

  resetScope: -> 
    delete @scope 
    @scope = new EssenceOfCoffeeScript.SourceCodeScope
    @scope.z =88
    @scope.title = @model.get 'title'

  materializeModel: ($elModel)->
    atts = $elModel.pickHTMLValues 'title',
      'headline',
      'description',
      'lesson',
      'js-syntax',
      'coffee-syntax',
      'example-code',
      'instruction',
      'given-code',
      'user-code',
      'user-console',
      'factoid'
    atts.instruction = [atts.instruction] if 'string' is typeof atts.instruction
    @model = new Backbone.Model atts

  
  display: () =>
    @$title.html @model.get 'title'
    @$headline.html @model.get 'headline'
    @$lesson.html @model.get 'lesson'
    @$description.html @model.get 'description'
    @$instructionList.html ''
    log 'instruction: ', @model.get 'instruction'
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
    @$outline.addClass('active')

  undisplay: (duration) =>
    @$el.fadeOut(@options.fadeOutDuration)
    @$outline.removeClass('active')
