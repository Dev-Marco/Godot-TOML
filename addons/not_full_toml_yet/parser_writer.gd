extends Node

enum _AdditionalType {NIL, HEX, OCT, BIN, DEC, DATE_TIME}

const _table_pattern = r"^\s*(?<table>(?:\[(?:[A-Za-z0-9_\-]+|\"(?:\\.|[^\"\\])*\"|'(?:[^'])*')" \
	+ r"(?:\.(?:[A-Za-z0-9_\-]+|\"(?:\\.|[^\"\\])*\"|'(?:[^'])*'))*\])" \
	+ r"|(?:\[\[(?:[A-Za-z0-9_\-]+|\"(?:\\.|[^\"\\])*\"|'(?:[^'])*')" \
	+ r"(?:\.(?:[A-Za-z0-9_\-]+|\"(?:\\.|[^\"\\])*\"|'(?:[^'])*'))*\]\]))$"

const _sub_table_pattern = r"(?<sub_table>[A-Za-z0-9_\-]+|\"(?:\\.|[^\"\\])*\"|'(?:[^'])*')"

const _key_value_pattern = r"^\s*(?<key>[A-Za-z0-9_\-]+" \
	+ r"|\"(?:\\." \
	+ r"|[^\"\\])+\"" \
	+ r"|'[^']+')\s*=\s*(?<value>\"(?:\\." \
	+ r"|[^\"\\])+\"" \
	+ r"|'[^']+'" \
	+ r"|[-+]?(?:\d(?:_\d)?)+(?:\.(?:\d(?:_\d)?)+)?(?:(?:e" \
	+ r"|E)[-+]?(?:\d(?:_\d)?)+(?:\.(?:\d(?:_\d)?)+)?)?" \
	+ r"|0x(?:[0-9A-Fa-f](?:_[0-9A-Fa-f])?)+" \
	+ r"|0o(?:[0-7](?:_[0-7])?)+" \
	+ r"|0b(?:[0-1](?:_[0-1])?)+" \
	+ r"|true|false" \
	+ r"|inf|\+inf|\-inf" \
	+ r"|nan|\+nan|\-nan" \
	+ r"|[0-9]\{4}\-(?:0[1-9]" \
	+ r"|1[0-2])\-(?:0[0-9]" \
	+ r"|[1-2][0-9]" \
	+ r"|3[0-1])(?:(?:T" \
	+ r"|\ )(?:0[0-9]" \
	+ r"|1[0-9]" \
	+ r"|2[0-3]):(?:0[0-9]" \
	+ r"|[1-5][0-9]):(?:0[0-9]" \
	+ r"|[1-5][0-9])(?:Z" \
	+ r"|\.[0-9]{1,6}(?:\-(?:0[0-9]" \
	+ r"|1[0-9]" \
	+ r"|2[0-3]):(?:0[0-9]" \
	+ r"|[1-5][0-9]))?" \
	+ r"|(?:\-(?:0[0-9]" \
	+ r"|1[0-9]" \
	+ r"|2[0-3]):(?:0[0-9]" \
	+ r"|[1-5][0-9]))?)?)?" \
	+ r"|(?:0[0-9]" \
	+ r"|1[0-9]" \
	+ r"|2[0-3]):(?:0[0-9]" \
	+ r"|[1-5][0-9]):(?:0[0-9]" \
	+ r"|[1-5][0-9])(?:Z" \
	+ r"|\.[0-9]{1,6})" \
	+ r"|\"\"" \
	+ r"|'')\s*(?:#.*)?$"

const _integer_pattern = r"^[+-]?\d+(?:_\d+)*$"
const _float_pattern = r"^[+-]?(?<value>\d+(?:_\d+)*(?:\.\d+(?:_\d+)*)?)(?:[eE](?<operator>[+-])?(?<exponent>\d+(?:_\d+)*))?$"
const _date_time_pattern = r"(?<year>\d{4})\-(?<month>0[1-9]|1[1-2])\-(?<day>0[1-9]|[1-2][0-9]|3[0-1])(?:T|\ )(?<hour>[0-1][0-9]|2[0-3]):(?<minute>[0-5][0-9]):(?<second>[0-5][0-9])$"

var _table_regex: RegEx = RegEx.create_from_string(_table_pattern)
var _sub_table_regex: RegEx = RegEx.create_from_string(_sub_table_pattern)
var _key_value_regex: RegEx = RegEx.create_from_string(_key_value_pattern)
var _integer_regex: RegEx = RegEx.create_from_string(_integer_pattern)
var _float_regex: RegEx = RegEx.create_from_string(_float_pattern)
var _date_time_regex: RegEx = RegEx.create_from_string(_date_time_pattern)


var _writer: _TomlWriter = _TomlWriter.new()

func parse(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)

	var data: Dictionary = {}
	var lines: Array[String] = []
	var head: _WriteHead = _WriteHead.new()


	while not file.eof_reached():
		lines.append(file.get_line())

	var parent: Dictionary = data
	var sub_tables: Array[String]

	for line in lines:
		line = line.strip_edges()
		# Nothing on this line
		if line.is_empty():
			continue
		# Comments are ignored
		if line.begins_with('#'):
			continue

		var key_value = _search_key_value(line)

		if not key_value.is_empty():
			#parent[key_value.key] = key_value.value
			head.write(key_value, data)
			continue

		var new_table: String = _search_table(line)
		var table: String = _search_table(line)
		if table.is_empty():
			continue

		var new_sub_tables = _search_sub_tables(table)
		if sub_tables != new_sub_tables:
			head.clear()
		sub_tables = new_sub_tables

		if sub_tables.size() == 1:
			parent = data
			head.clear()
			head.push(sub_tables[0])
			head.build({}, data, _table_is_list(table))
		else:
			head.go_to(sub_tables)
			head.build({}, data, _table_is_list(table))

	return data


func dump(path: String, data: Dictionary) -> void:
	_writer.dump(path, data)


func _search_table(line: String) -> String:
	var table_match: RegExMatch = _table_regex.search(line)
	if table_match == null:
		return ''
	return table_match.get_string('table')


func _search_sub_tables(table: String) -> Array[String]:
	var sub_table_matches: Array[RegExMatch] = _sub_table_regex.search_all(table)
	var sub_tables: Array[String] = []
	for sub_table_match in sub_table_matches:
		sub_tables.append(sub_table_match.get_string('sub_table'))
	return sub_tables


func _search_key_value(line: String) -> Dictionary:
	var key_value_match: RegExMatch = _key_value_regex.search(line)
	if key_value_match == null:
		return {}
	var key: String = key_value_match.get_string('key')
	var value: String = key_value_match.get_string('value')
	var type: int = TYPE_NIL
	var typed_value: Variant = null
	var additional_info: _AdditionalType = _AdditionalType.NIL
	if value.begins_with('"') or value.begins_with("'"):
		type = TYPE_STRING
		typed_value = value.substr(1, value.length() - 2)
	elif value == 'true' or value == 'false':
		type = TYPE_BOOL
		typed_value = value == 'true'
	elif value == 'nan' or value == '+nan' or value == '-nan':
		type = TYPE_FLOAT
		typed_value = NAN
	elif value == 'inf' or value == '+inf' or value == '-inf':
		type = TYPE_FLOAT
		typed_value = INF if value == 'inf' or value == '+inf' else -INF
	elif value.begins_with('0x'):
		type = TYPE_INT
		typed_value = value.hex_to_int()
		additional_info = _AdditionalType.HEX
	elif value.begins_with('0o'):
		type = TYPE_INT
		typed_value = oct_to_int(value)
		additional_info = _AdditionalType.OCT
	elif value.begins_with('0b'):
		type = TYPE_INT
		typed_value = value.bin_to_int()
		additional_info = _AdditionalType.BIN
	elif _is_integer(value):
		type = TYPE_INT
		typed_value = _search_integer(value)
		additional_info = _AdditionalType.DEC
	elif _is_float(value):
		type = TYPE_FLOAT
		typed_value = _search_float(value)
	elif _is_date_time(value):
		type = TYPE_STRING
		typed_value = _search_date_time(value)
		additional_info = _AdditionalType.DATE_TIME

	if type == TYPE_NIL or typed_value == null:
		return {}

	return {
		'type': type,
		'key': key,
		'value': typed_value,
		'additional_info': additional_info,
	}


func _search_float(value: String) -> float:
	var float_match: RegExMatch = _float_regex.search(value)
	var negative: bool = float_match.get_string().begins_with('-')
	var base: String = float_match.get_string('value').replace('_', '')
	var operator: String = float_match.get_string('operator')
	operator = '+' if operator.is_empty() else operator
	var exponent = float_match.get_string('exponent').replace('_', '')
	return float(base) * (10.0 ** float(operator + exponent)) * (-1 if negative else 1)


func _is_float(value: String) -> bool:
	return _float_regex.search(value) != null

func _search_integer(value: String) -> int:
	return int(_integer_regex.search(value).get_string().replace('_', ''))


func _is_integer(value: String) -> bool:
	return _integer_regex.search(value) != null


func _search_date_time(value: String) -> String:
	var dt_match: RegExMatch = _date_time_regex.search(value)
	var date_time = {
		'year': dt_match.get_string('year'),
		'month': dt_match.get_string('month'),
		'day': dt_match.get_string('day'),
		'hour': dt_match.get_string('hour'),
		'minute': dt_match.get_string('minute'),
		'second': dt_match.get_string('second'),
	}
	return '{year}-{month}-{day}T{hour}:{minute}:{second}'.format(date_time)


func _is_date_time(value: String) -> bool:
	return _date_time_regex.search(value) != null


func _table_is_list(table: String) -> bool:
	return table.begins_with('[[')


func oct_to_int(value: String) -> int:
	if value.begins_with('0o'):
		value = value.substr(2, value.length() - 2)
	var number: int = 0
	for i in range(value.length()):
		var digit = int(value[i])
		number += digit * (8 ** (value.length() - (i + 1)))
	return number


class _WriteHead:
	var _head: Array[String] = []
	var position: String:
		get:
			if _head.is_empty():
				return ''
			return _head.back()

	var parent: String:
		get:
			if _head.is_empty() or _head.size() == 1:
				return ''
			return _head[-2]

	func _to_string() -> String:
		return '.'.join(_head)


	func clear():
		_head = []


	func push(value: String) -> void:
		_head.append(value)


	func pop() -> String:
		if _head.is_empty():
			return ''
		var popped_value: String = _head.pop_back()
		return popped_value


	func go_to(pos: Array[String]) -> void:
		_head = pos


	func build(value: Dictionary, dict: Dictionary, is_list: bool = false) -> void:
		var obj: Dictionary = dict
		for i in range(_head.size()):
			var val = value.duplicate(true)
			var key: String = _head[i]
			if is_list and i == _head.size() - 1:
				obj = obj.get_or_add(key, [val])[0]
			elif is_list and obj.has(key) and obj[key] is Array:
				obj = obj[key].back()
			else :
				obj = obj.get_or_add(key, val)


	func write(key_value: Dictionary, target: Dictionary) -> void:
		if _head.is_empty():
			target[key_value.key] = key_value.value
			return

		var t: Variant = target
		for level: String in _head:
			t = t[level]
			if t is Array:
				t = t.back()

		t[key_value.key] = key_value.value



class _TomlWriter:
	func dump(path: String, data: Dictionary) -> void:
		var lines: Array[String] = []
		var sorted_data: Array[Dictionary] = _sort_dict(data)

		for dict in sorted_data:
			lines.append_array(_match_type(dict))

		var new_file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
		for line in lines:
			new_file.store_line(line)
		new_file.close()


	func _match_type(dict: Dictionary, pre: String = '', tab_level: int = 0) -> Array[String]:
		var lines: Array[String] = []
		var key = dict.key
		var value = dict.value
		var prefix: String = ''
		var tab: String = '  '.repeat(tab_level)
		if not pre.is_empty():
			prefix += pre + '.'

		match typeof(value):
				TYPE_BOOL:
					lines.append('{tab}{key} = {value}'.format({'tab': tab, 'key': key, 'value': value}))
				TYPE_INT:
					lines.append('{tab}{key} = {value}'.format({'tab': tab, 'key': key, 'value': value}))
				TYPE_FLOAT:
					lines.append('{tab}{key} = {value}'.format({'tab': tab, 'key': key, 'value': value}))
				TYPE_STRING:
					lines.append('{tab}{key} = \'{value}\''.format({'tab': tab, 'key': key, 'value': value}))
				TYPE_DICTIONARY:
					lines.append('')
					lines.append('[{prefix}{table_name}]'.format({'table_name': key, 'prefix': prefix}))
					for sub_dict in _sort_dict(value):
						lines.append_array(_match_type(sub_dict, '{prefix}{key}'.format({'prefix': prefix, 'key': key}), 1))
				TYPE_ARRAY:
					lines.append('')
					lines.append('[[{prefix}{array_name}]]'.format({'array_name': key, 'prefix': prefix}))
					for array_dict in value:
						for sub_dict in _sort_dict(array_dict):
							lines.append_array(_match_type(sub_dict, '{prefix}{key}'.format({'prefix': prefix, 'key': key}), 1))
		return lines


	func _sort_dict(data: Dictionary) -> Array[Dictionary]:
		var entries: Array[Dictionary] = []
		for key in data.keys():
			entries.append({'key': key, 'value': data[key]})
		entries.sort_custom(_sort_for_toml)
		return entries


	func _sort_for_toml(a: Dictionary, b: Dictionary):
		var t_a = typeof(a.value)
		var t_b = typeof(b.value)
		if (t_a == TYPE_DICTIONARY or t_a == TYPE_ARRAY) and (t_b != TYPE_DICTIONARY and t_b != TYPE_ARRAY):
			return false
		return true
