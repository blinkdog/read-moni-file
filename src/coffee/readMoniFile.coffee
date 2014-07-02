#!/usr/bin/env coffee
# readMoniFile.coffee
# Copyright 2014 WIPAC. All rights reserved
#----------------------------------------------------------------------

fs = require 'fs'

###
# match a category/time line like "foo: 2011-02-28 09:10:11.123456:"
CATTIME_PAT = re.compile(r"^([^:]+):\s(\d+-\d+-\d+\s\d+:\d+:\d+\.\d+)\s*")
###
CATTIME_PAT = /^([^:]+):\s(\d+-\d+-\d+\s\d+:\d+:\d+\.\d+)\s*/
exports.CATTIME_PAT = CATTIME_PAT

###
# match a data line like "    name: value"
DATA_PAT = re.compile(r"^(\s+)([^:]+):\s+(.*\S)\s*")
###
DATA_PAT = /^(\s+)([^:]+):\s+(.*\S)\s*/
exports.DATA_PAT = DATA_PAT

###
class MonitorFile(object):
###
class MonitorFile
  ###
  def __init__(self, filename):
      """
      Cache a pDAQ monitor file
      """
      self._data = self._read_file(filename)
  ###
  constructor: (@filename) ->
    @_data = @_read @filename

  ###
  @classmethod
  def _read_file(cls, filename):
  ###
  _read: (filename) ->
    ###
    "Read and parse a monitor file"
    data = {}
    curDict = None
    ###
    data = {}
    curDict = null

    ###
    for line in open(filename, "r"):
        line = line.rstrip()
    ###
    fileData = fs.readFileSync filename, 'utf8'
    lines = (line.trimRight() for line in fileData.split('\n'))
    for line in lines
      ###
      if len(line) == 0:
          curDict = None
          continue
      ###
      if line.length is 0
        curDict = null
        continue

      ###
      m = cls.CATTIME_PAT.match(line)
      if m is not None:
      ###
      m = CATTIME_PAT.exec line
      if m?
        ###
        cat = m.group(1)
        time = datetime.datetime.strptime(m.group(2),
                                          "%Y-%m-%d %H:%M:%S.%f")
        ###
        cat = m[1]
        # BUG: Sadly, millisecond precision is not going to cut it... :-(
        #time = Date.parse(m[2].replace(' ','T') + 'Z')
        time = m[2]
        ###
        if not time in data:
            data[time] = {}
        ###
        data[time] ?= {}
        ###
        curDict = {}
        data[time][cat] = curDict
        continue
        ###
        curDict = {}
        data[time][cat] = curDict
        continue

      ###
      m = cls.DATA_PAT.match(line)
      if m is not None:
      ###
      m = DATA_PAT.exec line
      if m?
        ###
        try:
            curDict[m.group(2)] = int(m.group(3))
        except:
            try:
                curDict[m.group(2)] = float(m.group(3))
            except:
                curDict[m.group(2)] = m.group(3)
        continue
        ###
        num = Number m[3]
        curDict[m[2]] = if Number.isNaN num then JSON.parse m[3].replace(/'/g,'"') else num
        continue

      ###
      print >>sys.stderr, "Bad line: " + line
      ###
      process.stderr.write "Bad line: #{line}\n"

    ###
    return data
    ###
    return data

  ###
  @classmethod
  def _write_data_to_file(cls, out, data):
  ###
  _write: (out, data) ->
    ###
    "Write data to a file in pDAQ .moni format"
    times = data.keys()
    times.sort()
    ###
    times = Object.keys data
    times.sort()
    ###
    need_nl = False
    ###
    need_nl = false
    ###
    for t in times:
    ###
    for t in times
      ###
      keys = data[t].keys()
      keys.sort()
      ###
      keys = Object.keys data[t]
      keys.sort()
      ###
      for k in keys:
      ###
      for k in keys
        ###
        if need_nl:
            print >>out
        else:
            need_nl = True
        ###
        if need_nl
          out.write '\n'
        else
          need_nl = true
        ###
        print >>out, "%s: %s" % (k, t)
        ###
        # BUG: Sadly, millisecond precision is not going to cut it... :-(
        #out.write "#{k}: #{t.toISOString().replace(/T/g,' ').replace(/Z/,'')}\n"
        out.write "#{k}: #{t}\n"
        ###
        names = data[t][k].keys()
        names.sort()
        ###
        names = Object.keys data[t][k]
        names.sort()
        ###
        for n in names:
        ###
        for n in names
          ###
          print >>out, "\t%s: %s" % (n, data[t][k][n])
          ###
          if typeof data[t][k][n] is 'number'
            d = data[t][k][n]
          else
            d = JSON.stringify(data[t][k][n])
                  .replace(/"/g, "'")            #  " --> '
                  .replace(/,/g, ", ")           # spaces after commas
                  .replace(/':/g, "': ")         # spaces after data colons
          out.write "\t#{n}: #{d}\n"

  ###
  def dump_data(self, out):
  ###
  dump: (out) ->
    ###
    "Dump data in pDAQ .moni format"
    self._write_data_to_file(out, self._data)
    ###
    @_write out, @_data

  ###
  def check_root(self):
  ###
  checkRoot: ->
    ###
    """
    Print an estimate of the time remaining before the root partition
    is full.
    """
    print "The root partition will NEVER FILL UP"
    ###
    process.stdout.write "The root partition will NEVER FILL UP\n"
    for time of @_data
      if @_data[time].system?
        if @_data[time]['system'].AvailableDiskSpace?
          if @_data[time]['system']['AvailableDiskSpace']['/']?
            process.stdout.write "#{time}: #{@_data[time]['system']['AvailableDiskSpace']['/']}\n"
    process.stdout.write "... or not.\n"

# make the MonitorFile class available by require()
exports.MonitorFile = MonitorFile

do ->
  ###
  if __name__ == "__main__":
  ###
  if process.argv[1].match /readMoniFile.coffee$/
    ###
    if len(sys.argv) == 1:
        raise SystemExit("Please specify a file to process")
    ###
    if process.argv.length < 2
      process.stdout.write "Please specify a file to process\n"
      process.exit 1

    ###
    for f in sys.argv[1:]:
        mf = MonitorFile(f)
        mf.dump_data(sys.stdout)
    ###
    files = process.argv[2..]
    for file in files
      mf = new MonitorFile file
      mf.dump process.stdout
      mf.checkRoot()

#----------------------------------------------------------------------
# end of readMoniFile.coffee
