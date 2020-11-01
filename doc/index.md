# Module `editor`

Public editor api

### [Functions](#Functions)

| Property                        | Description                                        |
| ------------------------------- | -------------------------------------------------- |
| Editor.addCommand (name, fn)    | Register a command, there is a max of 15 commands! |
| Editor.reject (msg)             | Alias for error                                    |
| Editor.editCurrentLine (text)   | Edit the current line of the editor                |
| Editor.editCursorPosition (pos) | Change the position of the cursor                  |
| Editor.getText ()               | Get the text from the editor                       |
| Editor.getCursorPosition ()     | Get the current cursor position                    |

## [Functions](#Functions)

### [Editor.addCommand (name, fn)](#Editor.addCommand)

Register a command, there is a max of 15 commands!

| Parameters | Type                                                                             | Optional | Default | Description                     |
| ---------- | -------------------------------------------------------------------------------- | -------- | ------- | ------------------------------- |
| name       | <a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a> | ❌       | `none`  | The name of the command         |
| fn         | <span class="type">function</span>                                               | ❌       | `none`  | The function to run the command |

### [Editor.reject (msg)](#Editor.reject)

Alias for error

| Parameters | Type                                                                             | Optional | Default | Description         |
| ---------- | -------------------------------------------------------------------------------- | -------- | ------- | ------------------- |
| msg        | <a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a> | ❌       | `none`  | The message to send |

### [Editor.editCurrentLine (text)](#Editor.editCurrentLine)

Edit the current line of the editor

| Parameters | Type                                                                             | Optional | Default | Description                   |
| ---------- | -------------------------------------------------------------------------------- | -------- | ------- | ----------------------------- |
| text       | <a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a> | ❌       | `none`  | What to replace the line with |

### [Editor.editCursorPosition (pos)](#Editor.editCursorPosition)

Change the position of the cursor

| Parameters | Type                             | Optional | Default | Description                     |
| ---------- | -------------------------------- | -------- | ------- | ------------------------------- |
| pos        | <span class="type">number</span> | ❌       | `none`  | The position to move the cursor |

### [Editor.getText ()](#Editor.getText)

Get the text from the editor

**Returns:** <span class="type">number</span> te

### [Editor.getCursorPosition ()](#Editor.getCursorPosition)

Get the current cursor position

**Returns:** <span class="type">number</span> positi
