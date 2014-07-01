#!/usr/bin/env coffee
# readMoniFile.coffee
# Copyright 2014 WIPAC. All rights reserved
#----------------------------------------------------------------------

###
#!/usr/bin/env python

import datetime
import re
import sys


class MonitorFile(object):
    # match a category/time line like "foo: 2011-02-28 09:10:11.123456:"
    #
    CATTIME_PAT = re.compile(r"^([^:]+):\s(\d+-\d+-\d+\s\d+:\d+:\d+\.\d+)\s*")

    # match a data line like "    name: value"
    #
    DATA_PAT = re.compile(r"^(\s+)([^:]+):\s+(.*\S)\s*")

    def __init__(self, filename):
        """
        Cache a pDAQ monitor file
        """
        self._data = self._read_file(filename)

    @classmethod
    def _read_file(cls, filename):
        "Read and parse a monitor file"
        data = {}

        curDict = None
        for line in open(filename, "r"):
            line = line.rstrip()

            if len(line) == 0:
                curDict = None
                continue

            m = cls.CATTIME_PAT.match(line)
            if m is not None:
                cat = m.group(1)
                time = datetime.datetime.strptime(m.group(2),
                                                  "%Y-%m-%d %H:%M:%S.%f")
                if not time in data:
                    data[time] = {}
                curDict = {}
                data[time][cat] = curDict
                continue

            m = cls.DATA_PAT.match(line)
            if m is not None:
                try:
                    curDict[m.group(2)] = int(m.group(3))
                except:
                    try:
                        curDict[m.group(2)] = float(m.group(3))
                    except:
                        curDict[m.group(2)] = m.group(3)
                continue

            print >>sys.stderr, "Bad line: " + line

        return data

    @classmethod
    def _write_data_to_file(cls, out, data):
        "Write data to a file in pDAQ .moni format"
        times = data.keys()
        times.sort()

        need_nl = False

        for t in times:
            keys = data[t].keys()
            keys.sort()
            for k in keys:
                if need_nl:
                    print >>out
                else:
                    need_nl = True

                print >>out, "%s: %s" % (k, t)

                names = data[t][k].keys()
                names.sort()
                for n in names:
                    print >>out, "\t%s: %s" % (n, data[t][k][n])

    def dump_data(self, out):
        "Dump data in pDAQ .moni format"
        self._write_data_to_file(out, self._data)

    def check_root(self):
        """
        Print an estimate of the time remaining before the root partition
        is full.
        """
        print "The root partition will NEVER FILL UP"


if __name__ == "__main__":
    if len(sys.argv) == 1:
        raise SystemExit("Please specify a file to process")

    for f in sys.argv[1:]:
        mf = MonitorFile(f)
        mf.dump_data(sys.stdout)
###
do ->
  process.stdout.write "Please specify a file to process\n"
  
#----------------------------------------------------------------------
# end of readMoniFile.coffee
