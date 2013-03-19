express = require 'express'
app = express()

port = process.env.PORT || 5000;

app.configure ->
  app.use express.logger()
  app.use express.basicAuth 'coffeescript', 'la'
  app.use express.static 'public'

app.get '/', (request, response)-> response.redirect '/essence.html'

app.listen port, -> console.log "Listening on " + port