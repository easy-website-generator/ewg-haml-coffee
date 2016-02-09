fs = require 'fs'

# this module exposes additional features for haml files
module.exports =
  external_path:(path) ->
    !!(path.indexOf('//') == 0 || path.indexOf('http') == 0)

  file_exists:(path) ->
    @ws.fileExists path

  append_asset_version: (input) ->
    time = Math.round((new Date()).getTime() / 1000)
    if input.indexOf('?') != -1
      return "#{input}&t=#{time}"

    return "#{input}?t=#{time}"

  inline_stylesheet_link_tag: (path) ->
    return path if @external_path(path)

    styles_path = @ws.distPathTo('styles', path)
    if @file_exists(styles_path)
      path = styles_path

    styles_path = @ws.distPathTo('public', path)
    if @file_exists(styles_path)
      path = styles_path

    @content_tag('style', fs.readFileSync(path, 'utf8'))

  inline_javascript_include_tag: (path) ->
    return path if @external_path(path)

    scripts_path = @ws.distPathTo('scripts', path)
    if @file_exists(scripts_path)
      path = scripts_path

    scripts_path = @ws.distPathTo('public', path)
    if @file_exists(scripts_path)
      path = scripts_path

    @content_tag('script', fs.readFileSync(path, 'utf8'))
