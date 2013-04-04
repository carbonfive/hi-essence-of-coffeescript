{ exec, spawn } = require 'child_process'

task 'jade', 'compile jade files', ->
  jader = exec "jade jade/index.jade -O ./public"
  jader.stdout.pipe process.stdout, end: false
  jader.stderr.pipe process.stderr, end: false

  jader = exec "jade jade/mockup.jade -O ./public"
  jader.stdout.pipe process.stdout, end: false
  jader.stderr.pipe process.stderr, end: false

  styler = exec "stylus stylus --out ./public/css"
  styler.stdout.pipe process.stdout, end: false
  styler.stderr.pipe process.stderr, end: false
