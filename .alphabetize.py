import re
import sys

def alphabetizeJava(filepath):
	language = languages[re.compile('java')]
	line_types = language['line_types']
	import_lines = []

	with open(filepath, 'r') as alphabetize_file:
		file_lines = alphabetize_file.readlines()
		for file_line in file_lines:
			if line_types['import'].match(file_line) is not None:
				import_lines.append(file_line)

		import_lines.sort()

		declares_package = line_types['package'].match(file_lines[0]) is not None

		remove_newlines_start_index = 0
		if declares_package:
			remove_newlines_start_index = 1

		insert_index = remove_newlines_start_index

		while (newline.match(file_lines[insert_index]) is not None or line_types['import'].match(file_lines[insert_index]) is not None):
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

	with open(filepath, 'w') as alphabetize_file:
		alphabetize_file.writelines(file_lines)

def alphabetizeJsp(filepath):
	language = languages[re.compile('jsp')]
	line_types = language['line_types']
	import_lines = []
	taglibs = []

	with open(filepath, 'r') as alphabetize_file:
		file_lines = alphabetize_file.readlines()
		for file_line in file_lines:
			if line_types['import'].match(file_line) is not None:
				import_lines.append(file_line)

			taglib_match = line_types['taglib'].search(file_line)
			if taglib_match is not None:
				attributes = taglib_match.group(1)
				attributes_list = attributes.split(' ')
				taglib = {attribute.split('=')[0]: attribute.split('=')[1] for attribute in attributes_list}
				taglibs.append(taglib)

		import_lines.sort()
		taglibs = sorted(taglibs, key=lambda x: x.get('prefix'))

		insert_index = 0

		while (newline.match(file_lines[insert_index]) is not None or any([line_type.match(file_lines[insert_index]) is not None for line_type in line_types.values()])):
			file_lines.pop(insert_index)

		import_prefix = None
		last_import_prefix = import_prefix

		for taglib in taglibs:
			if (taglib.get('tagdir') is not None):
				taglib_line = f"<%@ taglib prefix={taglib.get('prefix')} tagdir={taglib.get('tagdir')} %>\n"
			elif (taglib.get('uri') is not None):
				taglib_line = f"<%@ taglib prefix={taglib.get('prefix')} uri={taglib.get('uri')} %>\n"
			file_lines.insert(insert_index, taglib_line)
			insert_index+=1

		for import_line in import_lines:
			file_lines.insert(insert_index, import_line)
			insert_index+=1

		file_lines.insert(insert_index, "\n")
		insert_index+=1

	with open(filepath, 'w') as alphabetize_file:
		alphabetize_file.writelines(file_lines)

def alphabetizeCpp(filepath):
	language = languages[re.compile('[ch]pp')]
	line_types = language['line_types']
	angle_include_lines = []
	quote_include_lines = []

	with open(filepath, 'r') as alphabetize_file:
		file_lines = alphabetize_file.readlines()
		for file_line in file_lines:
			if line_types['angle_include'].match(file_line) is not None:
				angle_include_lines.append(file_line)

			if line_types['quote_include'].match(file_line) is not None:
				quote_include_lines.append(file_line)

		angle_include_lines.sort()
		quote_include_lines.sort()

		has_include_guard = line_types['ifndef'].match(file_lines[0]) is not None and line_types['define'].match(file_lines[1]) is not None

		remove_newlines_start_index = 0
		if has_include_guard:
			remove_newlines_start_index = 2

		insert_index = remove_newlines_start_index

		while (newline.match(file_lines[insert_index]) is not None or any([line_type.match(file_lines[insert_index]) is not None for line_type in line_types.values()])):
			file_lines.pop(insert_index)

		if has_include_guard:
			file_lines.insert(insert_index, "\n")
			insert_index+=1

		for angle_include_line in angle_include_lines:
			file_lines.insert(insert_index, angle_include_line)
			insert_index+=1

		file_lines.insert(insert_index, "\n")
		insert_index+=1

		for quote_include_line in quote_include_lines:
			file_lines.insert(insert_index, quote_include_line)
			insert_index+=1

		file_lines.insert(insert_index, "\n")
		insert_index+=1

	with open(filepath, 'w') as alphabetize_file:
		alphabetize_file.writelines(file_lines)

newline = re.compile("^\n$")

languages = {
	re.compile('java'): {
		'line_types': {
			'import': re.compile("^import .*$"),
			'package': re.compile("^package .*$")
		},
		'alphabetizer': alphabetizeJava
	},
	re.compile('jsp'): {
		'line_types': {
			'import': re.compile("^<%@ (?:page|tag) import.*%>$"),
			'taglib': re.compile("^<%@ taglib (.*) %>$")
		},
		'alphabetizer': alphabetizeJsp
	},
	re.compile('[ch]pp'): {
		'line_types': {
			'angle_include': re.compile("^#include <.*>$"),
			'quote_include': re.compile("^#include \".*\"$"),
			'ifndef': re.compile("^#ifndef .*$"),
			'define': re.compile("^#define .*$")
		},
		'alphabetizer': alphabetizeCpp
	}
}

def alphabetize(filepath):
	extension = filepath.split('.')[-1]
	for language_re, language in languages.items():
		if (language_re.fullmatch(extension) is not None):
			language['alphabetizer'](filepath)

for filepath in sys.argv[1:]:
	alphabetize(filepath)
