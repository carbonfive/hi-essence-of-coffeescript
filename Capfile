require 'capistrano/ext/multistage'
require 'capistrano/node-deploy'

set :stages, %w(acceptance production)
set :default_stage, 'acceptance'

set :application, 'coffeescript'
set :repository,  'git://github.com/carbonfive/hi-essence-of-coffeescript'
set :user, 'deploy'
set :scm, :git

role :app, 'boardroom.carbonfive.com'
