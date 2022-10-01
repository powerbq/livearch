#!/usr/bin/python3

import glob
import os
import re
import sys
from subprocess import Popen, PIPE

excluded_hooks = []

exit_code = 0

hooks_path = '/usr/share/libalpm/hooks'
hooks_files = []
for path, dirnames, filenames in os.walk(hooks_path):
    if path == hooks_path:
        for filename in filenames:
            if re.match('^[a-zA-Z0-9\-]+\.hook$', filename):
                hooks_files.append(hooks_path + '/' + filename)

            del filename

    del path, dirnames, filenames

del hooks_path

hooks_files.sort()

hooks = []
for hook_file in hooks_files:
    f = open(hook_file, 'r')
    lines = f.readlines()
    f.close()

    del f

    triggers = []

    trigger = None
    action = {'description': None, 'when': None, 'depends': None, 'exec': None, 'needstargets': False, 'abortonfail': False}

    hooks.append({'filename': os.path.basename(hook_file), 'triggers': triggers, 'action': action})

    is_trigger = False
    is_action = False

    for line in lines:
        if line == '\n':
            continue

        if line == '[Trigger]\n':
            is_trigger = True
            is_action = False

            trigger = {'operations': [], 'targets': [], 'exec': None}
            triggers.append(trigger)

            continue

        if line == '[Action]\n':
            is_action = True
            is_trigger = False

            continue

        matches = re.findall('^([a-zA-Z]+)\s*=\s*(.+)$', line)

        if len(matches) == 1 and len(matches[0]) == 2:
            key = matches[0][0].lower()
            val = matches[0][1]

            if is_trigger:
                if key in ['type', 'operation', 'target']:
                    if key == 'type':
                        trigger[key] = val
                    else:
                        trigger[key + 's'].append(val)

            if is_action:
                if key in ['description', 'when', 'depends', 'exec']:
                    action[key] = val

            del key, val

        if is_action and re.match('^[a-zA-Z]+$', line):
            line = line.lower().strip()
            if line in ['needstargets', 'abortonfail']:
                action[line] = True

        del matches
        del line

    del is_action, is_trigger
    del action, trigger, triggers
    del lines
    del hook_file

del hooks_files

conditions = ['PreTransaction', 'PostTransaction']
for condition in conditions:
    for hook in hooks:
        paths = []

        action = hook['action']
        filename = hook['filename']
        description = action['description']
        when = action['when']
        depends = action['depends']
        exec = action['exec']
        needstargets = action['needstargets']

        if when != condition:
            continue

        print('processing hook:', description)
        print('filename:', filename)
        print('when:', when)
        print('depends:', depends)

        if filename in excluded_hooks:
            print('skipping this hook (excluded)')
            print()

            continue

        will_run = False

        triggers = hook['triggers']

        for trigger in triggers:
            type = trigger['type']
            operations = trigger['operations']
            targets = trigger['targets']

            if type not in ['Path', 'Package']:
                del type

                continue

            if 'Install' not in operations:
                del type

                continue

            for target in targets:
                is_invert = False
                if target.startswith('!'):
                    is_invert = True
                    target = target[1:]

                if type == 'Path':
                    matches = glob.glob('/' + target)
                    cnt = len(matches)
                    if cnt == 0 and is_invert:
                        will_run = True
                    if cnt > 0 and not is_invert:
                        will_run = True
                        paths += matches

                    del cnt, matches
                if type == 'Package':
                    if not needstargets:
                        cmd = "pacman -Q | awk '{print $1}' | grep -P '^" + target + "$'"
                        proc = Popen(cmd, stdout=PIPE, shell=True)
                        out, err = proc.communicate()
                        cnt = len(out)
                        if cnt == 0 and is_invert:
                            will_run = True
                        if cnt > 0 and not is_invert:
                            will_run = True

                        del cmd, proc, out, err, cnt
                    else:
                        print('Not implemented')

                del is_invert, target
            del targets, operations, type, trigger

        if will_run:
            print('hook will run')

            input = needstargets and '\n'.join(paths).encode('utf-8') or None

            if input:
                print('paths:', paths)

            print('exec string:', exec)
            print('needstargets:', needstargets)

            proc = Popen(exec, stdin=PIPE, stdout=PIPE, stderr=PIPE, shell=True)
            out, err = proc.communicate(input=input)
            code = proc.returncode

            if code != 0:
                exit_code += 1

            out, err = '\n' + out.decode('utf-8'), '\n' + err.decode('utf-8')
            if len(out) == 1:
                out = 'empty stdout'

            if len(err) == 1:
                err = 'empty stderr'

            print('stdout:', out)
            print('stderr:', err)
            print('exit code:', code)

            print()

            del input, proc, out, err, code
        else:
            print('skipping this hook (not matched)')
            print()

        del triggers, paths, will_run, action, filename, description, when, depends, exec, hook

    del condition

del conditions, hooks, excluded_hooks

if exit_code == 0:
    print('all is ok')
else:
    print('something wrong')

sys.exit(exit_code)
