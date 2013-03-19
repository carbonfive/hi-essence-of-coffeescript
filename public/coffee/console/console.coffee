###
# This class wraps a JQConsole.
# https://github.com/replit/jq-console
# 
###

$ = $ || jQuery

class EssenceOfCoffeeScript.Console extends Backbone.View

  defaultOptions:
    header: 'CoffeeScript Console\n'
    prompt1: '>> '
    prompt2: '.. '

  initialize: (attributes) =>
    super attributes
    return console.error attributes, 'Element Not Found', attributes.el unless @$el.exists()
    {widgetEl, options, events, displaySettings} = attributes
    widgetEl = widgetEl || @el

    @$widgetEl = $(widgetEl)
    widgetEl = @$widgetEl[0]
    @launch options, displaySettings

  compileCoffeeScript: (sourceCode)=> '' + CoffeeScript.compile sourceCode, bare: on

  runCode: (command) =>
    javascriptSourceCode = @compileCoffeeScript(command)
    eval.call window, javascriptSourceCode

  launch: (options, displaySettings)->
    opts = _.extend {}, @defaultOptions, options
    { header, prompt1, prompt2 } = opts
    @jqconsole = @$el.jqconsole(header, prompt1, prompt2);

    @jqconsole.RegisterShortcut 'A', => @jqconsole.MoveToStart(); @jqconsoleHandler()
    @jqconsole.RegisterShortcut 'E', => @jqconsole.MoveToEnd(); @jqconsoleHandler()

    @jqconsole.RegisterMatching '{', '}', 'brace'
    @jqconsole.RegisterMatching '(', ')', 'paran'
    @jqconsole.RegisterMatching '[', ']', 'bracket'

    @jqconsoleHandler()
  
  clearCodeEditors: -> @codeEditors = []
  addCodeEditor: (editors...)=>
    @getCodeEditors().push editor for editor in editors when editor.runCode?

  getCodeEditors: =>
    @codeEditors = [] unless @codeEditors?
    @codeEditors

  jqconsoleHandler: (command)=>
    if command
      try
        editor.runCode() for editor in @getCodeEditors()
        result = @runCode command 
        output = switch typeof result
          when 'function'
            '[Function]'
          when 'object'
            JSON.stringify result, null, 0
          when 'undefined'
            ''
          else 
            JSON.stringify result, null, 1
        @jqconsole.Write '' + output + '\n'
      catch e
        @jqconsole.Write 'ERROR: ' + e.message + '\n'
    @jqconsole.Prompt true, @jqconsoleHandler, (command)->
      # Continue line if cant compile the command.
      try
        compiledJS = '' + CoffeeScript.compile command, bare: on
        Function compiledJS 
      catch e
        return 1 if /[\[\{\(]$/.test command
        return 0
      return false

  hide: ()=>
    @$widgetEl.fadeOut()

  show: (code)=>
    @aceEditor.setValue('')
    @aceEditor.insert(code)
    @$widgetEl.delay(100).fadeIn => @aceEditor.autoAdjustHeight()
