# nimclay

Nim wrapper for [clay](https://github.com/nicbarker/clay)

## Installation

Add this to your nimble file:

```nim
requires "https://github.com/Nimaoth/nimclay >= 0.1.0"
```

## Usage

See [here](tests/test2.nim) for more examples.

```nim
import clay

proc measureClayText(str: ptr ClayString, config: ptr ClayTextElementConfig): ClayDimensions {.cdecl.} =
  return ClayDimensions(width: str.length.float * 10, height: 20)

proc main() =
  let totalMemorySize = clay.minMemorySize()
  var memory = ClayArena(label: cs"my memory arena", capacity: totalMemorySize, memory: cast[cstring](allocShared0(totalMemorySize)))
  clay.initialize(memory, ClayDimensions(width: 1024, height: 768))
  clay.setMeasureTextFunction(measureClayText)

  var layoutElement = ClayLayoutConfig(padding: ClayPadding(x: 5, y: 10))
  var textConfig = ClayTextElementConfig(textColor: clayColor(1, 1, 1))

  # every frame
  clay.beginLayout()
  UI(rectangle(color = clayColor(1, 0, 0)), layout(layoutElement)):
    UI(rectangle(color = clayColor(0, 1, 0), cornerRadius = cornerRadius(1, 2, 3, 4)), layout(padding = ClayPadding(x: 20, y: 30))):
      clayText("hello", textColor = clayColor(0, 1, 1))
      clayText("world", textConfig)

  let renderCommands = clay.endLayout()
  # ...

main()
```
