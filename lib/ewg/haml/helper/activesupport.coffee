# this module overrides some active support methods for working paths etc.
module.exports =
  css_tag: (path, html_options) ->
    html_options = html_options || {}
    html_options.rel = 'stylesheet'
    html_options.href = path
    html_options.type = 'text/css'
    return @single_tag_for('link', html_options)

  path_to_stylesheet: (path, _options = {}) ->
    return path if @external_path(path)
    @append_asset_version @ws.uriPathTo('styles', path)

  path_to_javascript: (path, path_options={}) ->
    return path if @external_path path
    @append_asset_version @ws.uriPathTo('scripts', path)

  path_to_image: (path) ->
    return path if @external_path path
    @append_asset_version @ws.uriPathTo('images', path)

  image_tag:(path, options) ->
    @img_tag(@path_to_image(path), options)

  stylesheet_link_tag:(path, options) ->
    @css_tag(@path_to_stylesheet(path), options)

  javascript_include_tag:(path, options) ->
    @js_tag(@path_to_javascript(path), options)

  content_tag: (type, text, options) ->
    @start_tag_for(type, options)+text+@end_tag(type)

  options_for_select: (container) ->
    return container if typeof(container) == "string"

    result = []
    if {}.toString.call(container) is '[object Array]'
      for key in container
        result.push {text: key, value: key}
    else
      for key, value of container
        result.push {text: key, value: value}

    result
