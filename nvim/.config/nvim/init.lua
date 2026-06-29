require 'set'
require 'functions'
require 'maps'
require 'autocmd'
require 'commands'
require('plugin_loader').setup()
local project_loader = require 'project_loader'

require('vim._core.ui2').enable {}

project_loader.load_project()
