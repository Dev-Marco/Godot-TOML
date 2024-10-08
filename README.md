<img alt="TOML Parser Logo" src="https://github.com/Dev-Marco/Godot-TOML/blob/main/toml-parser-logo.png" width="200"/>

# A simple TOML Parser and Writer for the Godot Engine

A lightweight TOML parser and writer for the Godot Engine (version 4.3.stable), implemented in GDScript.

## Overview

This plugin provides the ability to parse simple TOML files and serialize data back into the TOML format within the Godot Engine. It supports basic parsing of dictionaries and arrays of objects, as well as commonly used data types. The primary goal is to offer a foundational TOML parsing capability that can be extended and improved over time.

**Please note:** This plugin is in the early stages of development (version 0.1.0). It is not feature-complete and is considered barebones at this point. The purpose of releasing this initial version is to gauge interest and receive feedback from the community.

## Features

- **Parsing Simple TOML Files:**
  - Supports basic key-value pairs.
  - Handles nested tables and arrays of tables.
  - **Note:** Currently, only arrays containing objects are supported. Arrays containing only primitive data types (e.g., `[1, 2, 3]`) are not yet implemented.
  - Parses commonly used data types:
    - **Strings:** Single and double-quoted strings.
    - **Integers:** Decimal, hexadecimal, octal, and binary formats.
    - **Floats:** Standard and scientific notation.
    - **Booleans:** `true` and `false`.
    - **Datetime Strings:** ISO 8601 formatted datetime strings.

- **Serializing Data to TOML:**
  - Converts Godot dictionaries and arrays of objects back into TOML format.
  - Maintains the structure of nested tables and arrays.

## Limitations

- **Incomplete Feature Set:**
  - Multiline strings and comments within data are not yet supported.
  - Inline arrays and inline tables are not implemented.
  - Arrays containing only primitive data types (e.g., numbers, strings) are not supported.
  - Does not handle all aspects of the TOML specification.

- **Regex-Based Parsing:**
  - The parser currently relies heavily on regular expressions. In future updates, there are plans to develop a more robust parsing mechanism.
  - For the current features, the regex approach is sufficient.

- **Potential Bugs:**
  - While some testing has been conducted, there may still be undiscovered bugs.
  - Comprehensive testing and bug fixes will be ongoing efforts.

- **No Documentation Yet:**
  - Comprehensive documentation and API references are pending.
  - Usage examples and code snippets will be added in future updates.

## Installation

1. **Download the Plugin:**
   - The plugin is available in the Godot Engine Asset Library under the name **"Not full TOML yet"**.
   - Alternatively, you can clone or download the repository and place it into your project's `addons/` directory.

2. **Enable the Plugin:**
   - In the Godot Editor, go to **Project** > **Project Settings** > **Plugins**.
   - Find the TOML Parser plugin in the list and enable it.
   - When the plugin is activated, it automatically creates an Autoload.

3. **Accessing the Singleton:**
   - The functions `parse` and `dump` are available via the singleton **`TOML`**.

## Usage

**Parsing a TOML File:**

Use the `parse` function provided by the `TOML` singleton to parse a **TOML** file and obtain a `Dictionary`.

```gdscript
var toml_data: Dictionary = TOML.parse("res://path/to/your_file.toml")
```

**Serializing Data to TOML:**

Use the `dump` function provided by the `TOML` singleton to serialize a `Dictionary` and write it to a **TOML** file.

```gdscript
TOML.dump("res://path/to/your_file.toml", data)
```

**Example Data Structure:**

```gdscript
var data = {
    "title": "Example",
    "owner": {
        "name": "John Doe",
        "dob": "1979-05-27T07:32:00"
    },
    "database": {
        "server": "192.168.1.1",
        "port": 8000
        "connection_max": 5000,
        "enabled": true
    }
}
```

By writing the above data to a **TOML** file with `parse` the output would look like this:

```toml
title = 'Example'

[database]
  enabled = true
  connection_max = 5000
  port = 8000
  server = '192.168.1.1'

[owner]
  dob = '1979-05-27T07:32:00'
  name = 'John Doe'
```

Please note that key-value pairs may appear in a different order. This is because, unlike arrays, dictionaries are typically unordered. If the need arises, I will consider adding a method to sort the output.

## Contributing

Contributions are welcome! Whether you want to report bugs, request features, or submit pull requests, your input is valuable.

- **Feedback:** Share your thoughts and let me know how this plugin can better serve your needs.
- **Issues:** If you encounter any problems, please open an issue with details.
- **Pull Requests:** For code contributions, please fork the repository and submit a pull request.

## Roadmap

- **Upcoming Features:**
  - Support for multiline strings and comments.
  - Implementation of inline arrays and inline tables.
  - Support for arrays containing primitive data types.
  - Comprehensive documentation and usage examples.
  - Improved error handling and validation.
  - Transition from regex-based parsing to a more robust parsing mechanism.

- **Community Involvement:**
  - Based on community feedback, prioritize features and improvements.
  - Encourage collaborative development and knowledge sharing.

## Contact

If you have any questions or need assistance, feel free to reach out. I'm happy to help and eager to hear your feedback.

## License

This project is open-source and available under the MIT License.

---

*This plugin is a work in progress, and your support and contributions are greatly appreciated. Together, we can enhance its capabilities and make it a valuable resource for the Godot community.*
