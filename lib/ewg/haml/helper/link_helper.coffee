# this module overrides some active support methods for working paths etc.
module.exports =
  link_to: (content, url = null, options = {}) ->
    url = content unless url
    options.href = url
    @content_tag('a', content, options)

  tel_to: (number_for_display, number = null, options = {}) ->
    number         = number_for_display unless number
    cleaned_number = number.replace(/\s*[-_/]*/gi, '')
    @link_to(number_for_display, "tel:#{cleaned_number}", options)

  mail_to: (email_for_display, email = null, options = {}) ->
    email = email_for_display unless email
    @link_to(email_for_display, "mailto:#{email}", options)

  maps_to: (place_for_display, place = null, options = {}) ->
    place = place_for_display unless place
    cleaned_place = encodeURIComponent(place.replace(/(<([^>]+)>)/ig,""))
    @link_to(place_for_display,
             "//www.google.de/maps/place/#{cleaned_place}",
             options)
