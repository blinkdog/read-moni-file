# readMoniFileTest.coffee
# Copyright 2014 WIPAC. All rights reserved
#----------------------------------------------------------------------

fs = require 'fs'
should = require 'should'

TEST_DATA_FILENAME = './testData/stringHub-80.moni'

describe 'readMoniFile', ->
  SH80 = fs.readFileSync TEST_DATA_FILENAME, 'utf8'
      
  describe 'CATTIME_PAT', ->
    {CATTIME_PAT} = require '../lib/readMoniFile'
    it 'should match a category/time line', ->
      "foo: 2011-02-28 09:10:11.123456:".should.match CATTIME_PAT

    it 'should return an array when exec on a category/time line', ->
      result = CATTIME_PAT.exec "foo: 2011-02-28 09:10:11.123456:"
      result.should.be.ok

    it 'should not match a data line', ->
      "    name: value".should.not.match CATTIME_PAT

    it 'should return null when exec on a data line', ->
      result = CATTIME_PAT.exec "    name: value"
      (result is null).should.be.true

    it 'should match some test data', ->
      matches = (line for line in SH80.split('\n') when line.match(CATTIME_PAT))
      matches.length.should.be.greaterThan 80

  describe 'DATA_PAT', ->
    {DATA_PAT} = require '../lib/readMoniFile'
    it 'should match a data line', ->
      "    name: value".should.match DATA_PAT

    it 'should return an array when exec on a data line', ->
      result = DATA_PAT.exec "    name: value"
      result.should.be.ok

    it 'should not match a category/time line', ->
      "foo: 2011-02-28 09:10:11.123456:".should.not.match DATA_PAT

    it 'should return null when exec on a category/time line', ->
      result = DATA_PAT.exec "foo: 2011-02-28 09:10:11.123456:"
      (result is null).should.be.true

    it 'should match some test data', ->
      matches = (line for line in SH80.split('\n') when line.match(DATA_PAT))
      matches.length.should.be.greaterThan 275
      
    it 'should match "	CurrentAquiredBuffers: 2"', ->
      "	CurrentAquiredBuffers: 2".should.match DATA_PAT
      result = DATA_PAT.exec "	CurrentAquiredBuffers: 2"
      result.should.be.ok

  describe 'MonitorFile', ->
    {MonitorFile} = require '../lib/readMoniFile'
    
    it 'should export a MonitorFile class', ->
      MonitorFile.should.be.ok
      
    it 'should be able to parse some test data', ->
      mf = new MonitorFile TEST_DATA_FILENAME
      mf._data.should.be.ok

#----------------------------------------------------------------------
# end of readMoniFileTest.coffee
