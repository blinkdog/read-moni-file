# Cakefile
#----------------------------------------------------------------------

{exec} = require 'child_process'

task 'link', 'Create softlink', ->
  link()

task 'rebuild', 'Rebuild project', ->
  clean -> compile -> copy -> test()

clean = (next) ->
  exec 'rm -fR lib/*', (err, stdout, stderr) ->
    throw err if err
    next?()

compile = (next) ->
  exec 'node_modules/coffee-script/bin/coffee -o lib/ -c src/coffee', (err, stdout, stderr) ->
    throw err if err
    next?()

copy = (next) ->
  exec 'cp src/js/* lib/', (err, stdout, stderr) ->
    throw err if err
    next?()

link = (next) ->
  exec 'ln -s src/coffee/readMoniFile.coffee', (err, stdout, stderr) ->
    throw err if err
    next?()

test = (next) ->
  exec 'node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive', (err, stdout, stderr) ->
    console.log stdout + stderr
    next?() if stderr.indexOf("AssertionError") < 0

#----------------------------------------------------------------------
# end of Cakefile

