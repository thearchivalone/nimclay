import std/[os, strformat, macros, genasts]
import clay

proc measureClayText(str: ptr ClayString, config: ptr ClayTextElementConfig): ClayDimensions {.cdecl.} =
  return ClayDimensions(width: str.length.float * 10, height: 20)

proc main() =
  let totalMemorySize = minMemorySize()
  var memory = ClayArena(label: cs"my memory arena", capacity: totalMemorySize, memory: cast[cstring](allocShared0(totalMemorySize)))
  echo &"totalMemorySize: {totalMemorySize shr 10} kb"
  clay.initialize(memory, ClayDimensions(width: 1024, height: 768))
  setMeasureTextFunction(measureClayText)
  var layoutElement = ClayLayoutConfig(padding: ClayPadding(x: 5, y: 10))
  var textConfig = ClayTextElementConfig(textColor: clayColor(1, 1, 1))
  clay.beginLayout()
  UI(rectangle(color = clayColor(1, 0, 0)), layout(layoutElement)):
    UI(rectangle(color = clayColor(0, 1, 0), cornerRadius = cornerRadius(1, 2, 3, 4)), layout(padding = ClayPadding(x: 20, y: 30))):
      clayText("hello", textColor = clayColor(0, 0, 1))
      clayText("world", textConfig)
  let renderCommands = clay.endLayout()
  let arr = cast[ptr UncheckedArray[ClayRenderCommand]](renderCommands.internalArray)

  echo "------------------------- BEGIN RENDERCOMMANDS"
  for i in 0..<renderCommands.length.int:
    echo arr[i]
    # echo arr[i].boundingBox
    # case arr[i].commandType
    # of Rectangle:
    #   echo arr[i].config.rectangleElementConfig[]
    # else: discard
  echo "------------------------- END RENDERCOMMANDS"

main()