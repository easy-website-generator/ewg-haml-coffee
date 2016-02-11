fs      = require 'fs'
map     = require 'map-stream'
hamlc   = require 'haml-coffee'
gutil   = require 'gulp-util'
extend  = require 'extend'
log     = require 'ewg-logging'
colors  = require 'colors'
htmlmin = require 'htmlmin'

PluginError    = gutil.PluginError
EWGHamlContext = require './context'
EWGHamlLayout  = require './layout'

defaultCompilerConfig =
  compiler: 'visionmedia'
  locals: ''
  uglify: false
  escapeHtml: false
  escapeAttributes: false
  extendScope: true

class EWGHamlRenderer
  constructor: (@config) ->
    extend(true, defaultCompilerConfig,
                 @config.compiler)

    @layout  = new EWGHamlLayout(@config)
    @context = new EWGHamlContext(@config)
    @context.extend
      render_partial: @renderPartial

    @lastContext = {}

  freshContext: (locals = {}) =>
    @lastContext = @context.new(locals)
    @lastContext

  renderContent: (content, context = {}, file = {}) =>
    log.yellow "rendering #{file}"
    output = undefined
    try
      output = hamlc.render(content, context, @config.compiler)
    catch e
      file = content unless file
      throw new PluginError('EWGHamlRenderer', 'Error compiling ' + file.yellow + ': ' + e, showStack: true)
    output

  renderPartial: (file, locals)=>
    @renderFileSync("#{@config.compiler.input_path}/#{file}.haml", locals)

  renderFileSync: (file, locals) =>
    unless fs.existsSync(file)
      throw new PluginError('EWGHamlRenderer', 'File not found ' + file.yellow , showStack: true)

    content = fs.readFileSync(file, 'utf8')
    @renderContent(content, extend(true, @lastContext, locals), file)

  renderFile: (file, locals, callback) =>
    fs.exists file, (exists) =>
      unless exists
        throw new PluginError('EWGHamlRenderer', 'File not found ' + file.yellow , showStack: true)

      fs.readFile file, 'utf8', (err, content) =>
        if err
          throw new PluginError('EWGHamlRenderer', 'File read error ' + file.yellow , showStack: true)

        callback @renderContent(content, extend(true, @lastContext, locals), file)

  resolveContentFor: (content, context) ->
    return content unless context.hasOwnProperty '__contentFor'

    for key, value of context.__contentFor
      content = content.replace("EWG_CONTENT_FOR_PLACEHOLDER_#{key}", value)

    content

  bodyClassFromFile: (file) ->
    tmp = file.split('/')
    tmp = tmp[tmp.length - 1]
    return tmp.replace('.html', '').replace('.haml', '').replace('.', '-')

  replaceExtension: (path) ->
    path = path.replace('.html', '').replace('.haml', '')
    path = path + @config.compiler.extension
    path.replace('..', '.')

  compileTemplate: (file, callback) =>
    log.green "rendering #{file.path}"

    if file.isNull()
      return callback(null, file)

    if file.toString()[0] == '_'
      return callback(null, file)

    if file.isStream()
      return callback(new Error('EWGHamlRenderer: Streaming not supported'))

    context       = @freshContext()
    content       = file.contents.toString('utf8')
    context.body  = @renderContent(content, context, file)

    # add a class to the body based on the rendered haml file
    context.body_class = @bodyClassFromFile(file.path)

    @layout.fromContent content, (layout) =>
      @renderFile layout, context, (output) =>
        output = @resolveContentFor(output, context)
        output = htmlmin(output, @config.minimize) if @config.minimize.enabled

        file.path     = @replaceExtension file.path
        file.contents = new Buffer(output)
        callback(null, file)

  # for gulp
  stream: () =>
    hamlStream = @compileTemplate
    map hamlStream

module.exports = EWGHamlRenderer
