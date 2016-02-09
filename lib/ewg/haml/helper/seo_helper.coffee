# this module exposes additional features for haml files
module.exports =
  copyright: (who, year) ->
    who  = '' unless who
    year = ' ' + new Date().getFullYear() + ' ' unless year
    "©#{year}#{who}"

  google_author_tag: (author_url) ->
    @link_tag author_url, 'author'

  canonical_tag: (canonical_url) ->
    @link_tag canonical_url, 'canonical'

  opengraph_tags: (og_properties) ->
    content = ''
    for key, value of og_properties
      content+= @meta_tag_property("og:#{key}", value)

    content

  twitter_tags: (twitter_proerties) ->
    content = ''
    for key, value of twitter_proerties
      content+= @meta_tag("twitter:#{key}", value)

    content
