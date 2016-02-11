fs  = require 'fs'
log = require 'ewg-logging'

class EWGHamlLayout
  constructor: (@config) ->
    @layoutPattern = /.*layout\:(.*)/i
    @defaultLayout = "#{@config.compiler.input_path}/#{@config.compiler.layout}"
    #            -# ewg layout: layout.haml

  fromContent: (content, callback) =>
    first = content.substr(0, content.indexOf("\n"))

    matches = first.match @layoutPattern
    if matches == null
      log.info "using layout #{@defaultLayout}"
      return callback @defaultLayout

    layout = "#{@config.compiler.input_path}/#{matches[1]}".replace(' ', '')

    fs.exists layout, (exists) =>
      unless exists
        log.error "could not find layout #{layout}"
        return callback @defaultLayout

      log.success "using layout #{layout}"
      return callback layout

module.exports = EWGHamlLayout
