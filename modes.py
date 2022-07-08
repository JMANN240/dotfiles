import os
import toml

home_path = os.path.expanduser('~')

with open(os.path.join(home_path, '.modes.toml'), 'r') as toml_file:
    modes = toml.load(toml_file)

lines = []

for mode, details in modes.items():
    enter_line = f"bind-key -n {details['key']} set-option key-table {mode}"
    exit_line = f"bind-key -T {mode} {details['key']} set-option key-table root"
    lines.append(enter_line)
    lines.append(exit_line)
    lines.append("")

    for key, command in details['keys'].items():
        key_line = f"bind-key -T {mode} {key} {command}"
        lines.append(key_line)
    lines.append("")

lines = [line + "\n" for line in lines]

with open(os.path.join(home_path, '.modes.conf'), 'w') as conf_file:
    conf_file.writelines(lines)
