window.EssenceOfCoffeeScript = window.EssenceOfCoffeeScript || {}

EssenceOfCoffeeScript.options = 
  fadeOutDuration: 1200
  fadeInDuration: 400

log = ->
  p = if console._log then console._log else console.log
  p arguments
