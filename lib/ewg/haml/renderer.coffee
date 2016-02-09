fs      = require 'fs'
map     = require 'map-stream'
rext    = require 'replace-ext'
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
      throw new PluginError('EWGHamlRenderer', 'Error compiling '
                              + file.yellow + ': ' + e, showStack: true)
    output

  renderPartial: (file, locals)=>
    @renderFile("#{@config.compiler.input_path}/#{file}.haml", locals)

  renderFile: (file, locals) =>
    unless fs.existsSync(file)
      throw new PluginError('EWGHamlRenderer', 'File not found '
                              + file.yellow , showStack: true)

    content = fs.readFileSync(file, 'utf8')
    @renderContent(content, extend(true, @lastContext, locals), file)

  resolveContentFor: (content, context) ->
    return content unless context.hasOwnProperty '__contentFor'

    for key, value of context.__contentFor
      content = content.replace("EWG_CONTENT_FOR_PLACEHOLDER_#{key}", value)

    content

  bodyClassFromFile: (file) ->
    tmp = file.split('/')
    tmp = tmp[tmp.length - 1]
    return tmp.replace('.html', '').replace('.haml', '').replace('.', '-')

  compileTemplate: (file, cb) =>
    log.green "rendering #{file.path}"

    if file.isNull()
      return cb(null, file)

    if file.toString()[0] == '_'
      return cb(null, file)

    if file.isStream()
      return cb(new Error('EWGHamlRenderer: Streaming not supported'))

    context       = @freshContext()
    content       = file.contents.toString('utf8')
    context.body  = @renderContent(content, context, file)

    # add a class to the body based on the rendered haml file
    context.body_class = @bodyClassFromFile(file.path)


    layout = @layout.fromContent content
    output = @renderFile(layout, context)
    output = @resolveContentFor(output, context)
    output = htmlmin(output, @config.minimize) if @config.minimize.enabled

    file.path     = rext(file.path, @config.compiler.extension)
    file.contents = new Buffer(output)
    cb(null, file)

  # for gulp
  stream: () =>
    hamlStream = @compileTemplate
    map hamlStream

module.exports = EWGHamlRenderer
