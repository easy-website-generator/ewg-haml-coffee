extend = require 'extend'

isArray  = ( value ) -> return {}.toString.call( value ) is '[object Array]'
isString = ( value ) -> return typeof(value) == "string"
isObject = ( value ) -> return {}.toString.call( value ) is "[object Object]"


class Globals
  constructor: (@globals) ->
    extend(true, @, @globals)

  get: (key, defaultValue) =>
    return defaultValue unless @globals.hasOwnProperty key

    @resolve @globals[key]

  resolve: (value) =>
    value = extend({}, value)
    if isObject(value)
      return @resolveHash(value)
    else if isArray(value)
      return @resolveArray(value)
    else
      return @resolveAtom(value)

  resolveHash: (myHash) =>
    for own key, value of myHash
      if isObject(value)
        myHash[key] = @resolveHash(value)
      else if isArray(value)
        myHash[key] = @resolveArray(value)
      else
        myHash[key] = @resolveAtom(value)
    myHash

  resolveArray: (myArray) =>
    for value, index in myArray
      if isArray(value)
        myArray[index] = @resolveArray(value)
      else if isObject(value)
        myArray[index] = @resolveHash(value)
      else
        myArray[index] = @resolveAtom(value)
    myArray

  resolveAtom: (atom) ->
    return atom unless atom
    return atom unless isString(atom)

    if atom.indexOf('@globals.') == 0
      return eval(atom.replace('@globals.', 'this.'))

    return atom

module.exports = Globals
