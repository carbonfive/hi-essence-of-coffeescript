{ exec, spawn } = require 'child_process'

task 'jade', 'compile jade files', ->
  jader = exec "jade jade/index.jade -O ./public"
  jader.stdout.pipe process.stdout, end: false
  jader.stderr.pipe process.stderr, end: false
