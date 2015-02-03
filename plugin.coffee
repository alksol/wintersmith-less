less = require 'less'
path = require 'path'
async = require 'async'
fs = require 'fs'

module.exports = (env, callback) ->

  class LessPlugin extends env.ContentPlugin

    constructor: (@filepath, @source) ->

    getFilename: ->
      @filepath.relative.replace /less$/, 'css'

    getView: ->
      return (env, locals, contents, templates, callback) ->
        options = env.config.less or {}
        options.filename = @filepath.relative
        options.paths = [path.dirname(@filepath.full)]
        # less throws errors all over the place...
        async.waterfall [
          (callback) =>
            try
              less.render(@source, options, callback)
            catch error
              callback error
          (output, callback) =>
            try
              callback null, new Buffer(output.css)
            catch error
              callback error
        ], callback

  LessPlugin.fromFile = (filepath, callback) ->
    fs.readFile filepath.full, (error, buffer) ->
      if error
        callback error
      else
        callback null, new LessPlugin filepath, buffer.toString()

  env.registerContentPlugin 'styles', '**/[^\_]*.less', LessPlugin
  callback()
