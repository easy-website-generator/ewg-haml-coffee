# this module exposes additional features for haml files
module.exports =
  meta_tag: (type, content) ->
    '<meta name="' + type + '" content="' + content + '" />'

  meta_tag_http: (type, content) ->
    '<meta http-equiv="' + type + '" content="' + content + '" />'

  link_tag: (source, relation) ->
    type = if type then " type='#{type}'" else ''
    '<link rel="' + relation + '" href="' + source + '"' + type + '/>'

  meta_tag_property: (type, content) ->
    '<meta property="' + type + '" content="' + content + '" />'
