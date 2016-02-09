fs  = require 'fs'
log = require 'ewg-logging'

class EWGHamlLayout
  constructor: (@config) ->
    @layoutPattern = /.*layout\:(.*)/i
    @defaultLayout = "#{@config.compiler.input_path}/#{@config.compiler.layout}"
    #            -# ewg layout: layout.haml

  fromContent: (content) =>
    first = content.substr(0, content.indexOf("\n"))

    matches = first.match @layoutPattern
    if matches == null
      log.info "using layout #{@defaultLayout}"
      return @defaultLayout

    layout = "#{@config.compiler.input_path}/#{matches[1]}".replace(' ', '')

    unless fs.existsSync(layout)
      log.error "could not find layout #{layout}"
      return @defaultLayout

    log.success "using layout #{layout}"
    layout

module.exports = EWGHamlLayout
