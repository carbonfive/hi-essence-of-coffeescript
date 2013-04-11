$ = $ || jQuery

class EssenceOfCoffeeScript.Console extends Backbone.View

  initialize: (attributes) =>
    super attributes
    return console.error attributes, 'Element Not Found', attributes.el unless @$el.exists()
    {widgetEl, options, events, displaySettings} = attributes
    widgetEl = widgetEl || @el

    @$widgetEl = $(widgetEl)
    widgetEl = @$widgetEl[0]
    @active = false
    @launch options, displaySettings

  activate: ()=>  @active = true

  deactivate: ()=>  @active = false

  launch: (options, displaySettings)-> $('html').on('log', @listenToConsoleLog)
  
  listenToConsoleLog: (event, { args })=> @Write args...

  WriteError: (args...)=>  @writeOutput 'error', args...
  Write: (args...)=> @writeOutput 'output', args...

  writeOutput: (css, args...)=> 
    return unless @active
    css ?= ''
    for arg in args
      output = switch typeof arg
        when 'undefined' then css += ' dim'; 'undefined'
        when 'function' then css += ' dim'; '[Function]'
        when 'string' then arg
        # when 'object' then JSON.stringify result, null, 0
        else JSON.stringify arg, null, 1
      @$el.append "<div class='#{css}'>#{output}</div>"
    @scrollToEnd()

  hide: ()=> @$widgetEl.fadeOut()

  show: (code)=> @$widgetEl.delay(100).fadeIn()

  scrollToEnd: ()=> @$el.animate { scrollTop: @$el[0].scrollHeight}, 80
