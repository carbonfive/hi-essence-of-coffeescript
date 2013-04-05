express = require 'express'
app = express()

port = process.env.PORT || 5000

allowCORS = (request, response, next)-> response.header('Access-Control-Allow-Origin', '*'); next()

app.configure ->
  app.use express.logger()
  app.use allowCORS
  app.use express.static "#{__dirname}/public"

app.listen port, -> console.log "Listening on " + port
