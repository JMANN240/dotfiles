import os
import toml

home_path = os.path.expanduser('~')

with open(os.path.join(home_path, '.modes.toml'), 'r') as toml_file:
    modes_config = toml.load(toml_file)

modes = modes_config.keys()

lines = []

for mode, details in modes_config.items():
    side_effect = ""
    anti_side_effect = ""

    if (details.get('side_effect', '') != ""):
        side_effect += f" \; {details.get('side_effect', '')}"

    if (details.get('anti_side_effect', '') != ""):
        anti_side_effect += f" \; {details.get('anti_side_effect', '')}"


    if details.get('copy', False):
        side_effect += " \; copy-mode"
        anti_side_effect += " \; send-keys -X cancel"

    for possible_mode in [m for m in modes if m != mode]:
        lines.append(f"bind-key -T {possible_mode} {details['key']} set-option key-table {mode}{side_effect}")

    exit_line = f"bind-key -T {mode} {details['key']} set-option key-table root{anti_side_effect}"
    lines.append(exit_line)

    lines.append("")

    keybinds = details.get('keys', {})
    if len(keybinds.items()) > 0:
        for key, command in keybinds.items():
            key_line = f"bind-key -T {mode} {key} {command}"
            lines.append(key_line)
        lines.append("")

    keyunbinds = details.get('unkeys', {})
    if len(keyunbinds) > 0:
        for key in keyunbinds:
            key_line = f"bind-key -T {mode} {key} send-keys {key}"
            lines.append(key_line)
        lines.append("")

    copykeybinds = details.get('copykeys', {})
    if len(copykeybinds.items()) > 0:
        for key, command in copykeybinds.items():
            side_effect = ""
            if "cancel" in command:
                side_effect += " \; set-option key-table root"
            key_line = f"bind-key -T {mode} {key} send-keys -X {command}{side_effect}"
            lines.append(key_line)
        lines.append("")

lines = [line + "\n" for line in lines]

with open(os.path.join(home_path, '.modes.conf'), 'w') as conf_file:
    conf_file.writelines(lines)
