{EWGHamlRenderer} = require '../index'
expect  = require('chai').expect
spy     = require('sinon').spy
File    = require 'vinyl'
fs      = require 'fs'

open = (path) ->
  tmp = new File "./test/fixtures/src/views/#{path}"
  tmp.path     = "./test/fixtures/src/views/#{path}"
  tmp.contents = new Buffer(fs.readFileSync("./test/fixtures/src/views/#{path}", 'utf-8'))
  tmp

describe 'ewg/logging', ->
  config =
    compiler:
      custom_helper:[
        './test/fixtures/src/lib/**/*.coffee'
      ]
      format: 'html5'
      extension: ''
      input_path:  './test/fixtures/src/views'
      output_path: './test/fixtures/dist'
      layout: 'layout.haml'
    minimize:
      enabled: true
      collapseWhitespace: true
      removeComments: true
      minifyJS: true
      minifyCSS: true
    globals:
      global_var: 'global_var_value'


  renderer = new EWGHamlRenderer(config)

  describe '#bodyClassFromFile()', ->
    it 'calculates the correct body class', ->
      bodyClass = renderer.bodyClassFromFile('foo/bar/test.index.html.haml')
      expect( bodyClass ).to.equal 'test-index'

  describe '#compileTemplate()', ->
    it 'renders default layout and template', (done) ->
      renderer.compileTemplate open('index.html.haml'), (err, file) ->
        expect( file.contents.toString('utf-8') ).to.contain 'layout.default'
        expect( file.contents.toString('utf-8') ).to.contain 'index.html'

        done()

    it 'renders another layout', (done)->
      renderer.compileTemplate open('index.blank.html.haml'), (err, file) ->
        expect( file.contents.toString('utf-8') ).to.contain 'layout.blank'
        expect( file.contents.toString('utf-8') ).to.contain 'index.blank.html'
        done()

    it 'renders a partial', (done)->
      renderer.compileTemplate open('partial.html.haml'), (err, file) ->
        expect( file.contents.toString('utf-8') ).to.contain 'layout.default'
        expect( file.contents.toString('utf-8') ).to.contain 'partial.html'
        expect( file.contents.toString('utf-8') ).to.contain '_partial.haml'
        done()

    describe 'helper feature', ->
      it 'includes ewg and custom helper', (done)->
        renderer.compileTemplate open('helper.html.haml'), (err, file) ->
          expect( file.contents.toString('utf-8') ).to.contain 'layout.default'
          expect( file.contents.toString('utf-8') ).to.contain 'helper.html'
          expect( file.contents.toString('utf-8') ).to.contain '©yearwho'
          expect( file.contents.toString('utf-8') ).to.contain 'custom_helper'
          done()

    describe ':content-for', ->
      it 'can render a content for block', (done)->
        renderer.compileTemplate open('content-for.html.haml'), (err, file) ->
          expect( file.contents.toString('utf-8') ).to.contain 'layout.default'
          expect( file.contents.toString('utf-8') ).to.contain 'content-for.html'
          expect( file.contents.toString('utf-8') ).to.contain 'content-for-test'
          done()
