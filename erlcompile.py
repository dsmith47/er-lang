#!/usr/bin/env python3

import sys
import subprocess

if __name__ == '__main__':
    try:
        prog_name = sys.argv[1].split('.')[0]
        function_name = sys.argv[2] if len(sys.argv) > 2 else 'start'
    except:
        print('usage: erlcompile.py <prog_name> <function_name>')
        exit(1)

    subprocess.call(['erlc', prog_name + '.erl'])
    subprocess.call(['erl', '-noshell', '-s', prog_name, function_name])

