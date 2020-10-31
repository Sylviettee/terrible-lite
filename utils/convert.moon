import parse from require 'toml'

(data) ->
  data = parse data

  code = ""

  convertType = (type) ->
    types = {
      'nil': 'NULL',
      'number': 'REAL',
      'string': 'TEXT',
      'blob': 'BLOB',
      'boolean': 'BIT'
    }
    types[type]

  convertValue = (value) ->
    values = {
      'boolean': "#{(value == true and '1') or (value == false and '0')}",
      'number': value,
      'string': "\"#{value}\""
    }

    values[type value]

  for object,properties in pairs data
    if object != 'CONFIGURATION'
      code = "#{code}CREATE TABLE IF NOT EXISTS #{object}s ("

      for setting, config in pairs properties
        code = "#{code}#{setting} #{(type(config.type) == 'table' and (convertType(type config.default) or (convertType config.realType) or 'TEXT')) or convertType config.type}#{((config.primaryKey or not config.default) and ' NOT NULL') or ''}#{(config.primaryKey and ' PRIMARY KEY') or ''}#{((not config.primaryKey and config.default) and ' DEFAULT ' .. convertValue config.default) or ''},"

      code = "#{code\sub 0, #code - 1});\n"

  code

