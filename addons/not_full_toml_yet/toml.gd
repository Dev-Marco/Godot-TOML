@tool
extends EditorPlugin

const autoload_name: String = 'TOML'
const script_path: String = 'res://addons/not_full_toml_yet/parser_writer.gd'

func _enter_tree() -> void:
	if not ProjectSettings.has_setting('autoload/' + autoload_name):
		add_autoload_singleton(autoload_name, script_path)


func _exit_tree() -> void:
	if ProjectSettings.has_setting('autoload/' + autoload_name):
		remove_autoload_singleton(autoload_name)
