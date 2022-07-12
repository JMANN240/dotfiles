import re
import sys

import_line = re.compile("^import .*$")
package_line = re.compile("^package .*$")
newline_line = re.compile("^\n$")

def alphabetize(filepath):
	global import_line, package_line, newline_line
	import_lines = []

	with open(filepath, 'r') as test_file:
		file_lines = test_file.readlines()
		for file_line in file_lines:
			if import_line.match(file_line) is not None:
				import_lines.append(file_line)

		import_lines.sort()

		imports_number = len(import_lines)

		declares_package = package_line.match(file_lines[0]) is not None

		remove_newlines_start_index = 0
		if declares_package:
			remove_newlines_start_index = 1
		
		insert_index = remove_newlines_start_index
		
		while (newline_line.match(file_lines[insert_index]) is not None or import_line.match(file_lines[insert_index]) is not None):
			file_lines.pop(insert_index)
		
		if declares_package:
			file_lines.insert(insert_index, "\n")
			insert_index+=1

		import_prefix = None
		last_import_prefix = import_prefix

		for import_line in import_lines:
			import_prefix = import_line.split(' ')[1].split('.')[0]
			if import_prefix != last_import_prefix and last_import_prefix is not None:
				file_lines.insert(insert_index, "\n")
				insert_index+=1
			file_lines.insert(insert_index, import_line)
			insert_index+=1
			last_import_prefix = import_prefix
		
		file_lines.insert(insert_index, "\n")
		insert_index+=1

	with open(filepath, 'w') as test_file:
		test_file.writelines(file_lines)

for filepath in sys.argv[1:]:
	alphabetize(filepath)
