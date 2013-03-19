express = require 'express'

port = process.env.PORT || 5000;

app = express.createServer express.logger()
app.get '/', (request, response)-> response.send 'Hello World!'

app.listen port, -> console.log "Listening on " + port