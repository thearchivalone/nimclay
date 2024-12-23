import std/[macros, genasts]

{.compile: "clay.c".}

type
  ElementConfigType* {.size: sizeof(cuint).} = enum
    Rectangle = 1,
    BorderContainer = 2,
    FloatingContainer = 4,
    ScrollContainer = 8,
    Image = 16,
    Text = 32,
    Custom = 64,

  LayoutDirection* {.size: sizeof(cuint).} = enum
    LeftToRight
    TopToBottom

  LayoutAlignmentX* {.size: sizeof(cuint).} = enum
    Left
    Right
    Center

  LayoutAlignmentY* {.size: sizeof(cuint).} = enum
    Top
    Bottom
    Center

  SizingType* {.size: sizeof(cuint).} = enum
    Fit
    Grow
    Percent
    Fixed

  FloatingAttachPointType* {.size: sizeof(cuint).} = enum
    LeftTop
    LeftCenter
    LeftBottom
    CenterTop
    CenterCenter
    CenterBottom
    RightTop
    RightCenter
    RightBottom

  TextElementConfigWrapMode* {.size: sizeof(cuint).} = enum
    Words = 0, Newlines = 1, None = 2

  PointerCaptureMode* {.size: sizeof(cuint).} = enum
    Capture = 0, Passthrough = 1

  RenderCommandType* {.size: sizeof(cuint).} = enum
    None = 0, Rectangle = 1, Border = 2, Text = 3, Image = 4,
    ScissorStart = 5, ScissorEnd = 6, Custom = 7

  PointerDataInteractionState* {.size: sizeof(cuint).} = enum
    PressedThisFrame = 0, Pressed = 1, ReleasedThisFrame = 2, Released = 3

  ClayString* {.pure, inheritable, bycopy.} = object
    length*: cint
    chars*: cstring
  ClayStringArray* {.pure, inheritable, bycopy.} = object
    capacity*: uint32
    length*: uint32
    internalArray*: ptr ClayString
  ClayArena* {.pure, inheritable, bycopy.} = object
    label*: ClayString
    nextAllocation*: uint64
    capacity*: uint64
    memory*: cstring
  ClayDimensions* {.pure, inheritable, bycopy.} = object
    width*: cfloat
    height*: cfloat
  ClayVector2* {.pure, inheritable, bycopy.} = object
    x*: cfloat
    y*: cfloat
  ClayColor* {.pure, inheritable, bycopy.} = object
    r*: cfloat
    g*: cfloat
    b*: cfloat
    a*: cfloat
  ClayBoundingBox* {.pure, inheritable, bycopy.} = object
    x*: cfloat
    y*: cfloat
    width*: cfloat
    height*: cfloat
  ClayElementId* {.pure, inheritable, bycopy.} = object
    id*: uint32
    offset*: uint32
    baseId*: uint32
    stringId*: ClayString
  ClayCornerRadius* {.pure, inheritable, bycopy.} = object
    topLeft*: cfloat
    topRight*: cfloat
    bottomLeft*: cfloat
    bottomRight*: cfloat
  ClayChildAlignment* {.pure, inheritable, bycopy.} = object
    x*: LayoutAlignmentX
    y*: LayoutAlignmentY
  ClaySizingMinMax* {.pure, inheritable, bycopy.} = object
    min*: cfloat
    max*: cfloat
  ClaySizingAxisUnion* {.union, bycopy.} = object
    sizeMinMax*: ClaySizingMinMax
    sizePercent*: cfloat
  ClaySizingAxis* {.pure, inheritable, bycopy.} = object
    union*: ClaySizingAxisUnion
    typ*: SizingType
  ClaySizing* {.pure, inheritable, bycopy.} = object
    width*: ClaySizingAxis
    height*: ClaySizingAxis
  ClayPadding* {.pure, inheritable, bycopy.} = object
    x*: uint16
    y*: uint16
  ClayLayoutConfig* {.pure, inheritable, bycopy.} = object
    sizing*: ClaySizing
    padding*: ClayPadding
    childGap*: uint16
    childAlignment*: ClayChildAlignment
    layoutDirection*: LayoutDirection
  ClayRectangleElementConfig* {.pure, inheritable, bycopy.} = object
    color*: ClayColor
    cornerRadius*: ClayCornerRadius
  ClayTextElementConfig* {.pure, inheritable, bycopy.} = object
    textColor*: ClayColor
    fontId*: uint16
    fontSize*: uint16
    letterSpacing*: uint16
    lineHeight*: uint16
    wrapMode*: TextElementConfigWrapMode
  ClayImageElementConfig* {.pure, inheritable, bycopy.} = object
    imageData*: pointer
    sourceDimensions*: ClayDimensions
  ClayFloatingAttachPoints* {.pure, inheritable, bycopy.} = object
    element*: FloatingAttachPointType
    parent*: FloatingAttachPointType
  ClayFloatingElementConfig* {.pure, inheritable, bycopy.} = object
    offset*: ClayVector2
    expand*: ClayDimensions
    zIndex*: uint16
    parentId*: uint32
    attachment*: ClayFloatingAttachPoints
    pointerCaptureMode*: PointerCaptureMode
  ClayCustomElementConfig* {.pure, inheritable, bycopy.} = object
    customData*: pointer
  ClayScrollElementConfig* {.pure, inheritable, bycopy.} = object
    horizontal*: bool
    vertical*: bool
  ClayBorder* {.pure, inheritable, bycopy.} = object
    width*: uint32
    color*: ClayColor
  ClayBorderElementConfig* {.pure, inheritable, bycopy.} = object
    left*: ClayBorder
    right*: ClayBorder
    top*: ClayBorder
    bottom*: ClayBorder
    betweenChildren*: ClayBorder
    cornerRadius*: ClayCornerRadius
  ClayElementConfigUnion* {.union, bycopy.} = object
    rectangleElementConfig*: ptr ClayRectangleElementConfig
    textElementConfig*: ptr ClayTextElementConfig
    imageElementConfig*: ptr ClayImageElementConfig
    floatingElementConfig*: ptr ClayFloatingElementConfig
    customElementConfig*: ptr ClayCustomElementConfig
    scrollElementConfig*: ptr ClayScrollElementConfig
    borderElementConfig*: ptr ClayBorderElementConfig
  ClayElementConfig* {.pure, inheritable, bycopy.} = object
    type_field*: ElementConfigType
    config*: ClayElementConfigUnion
  ClayScrollContainerData* {.pure, inheritable, bycopy.} = object
    scrollPosition*: ptr ClayVector2
    scrollContainerDimensions*: ClayDimensions
    contentDimensions*: ClayDimensions
    config*: ClayScrollElementConfig
    found*: bool
  ClayRenderCommand* {.pure, inheritable, bycopy.} = object
    boundingBox*: ClayBoundingBox
    config*: ClayElementConfigUnion
    text*: ClayString
    id*: uint32
    commandType*: RenderCommandType
  ClayRenderCommandArray* {.pure, inheritable, bycopy.} = object
    capacity*: uint32
    length*: uint32
    internalArray*: ptr ClayRenderCommand
  ClayPointerData* {.pure, inheritable, bycopy.} = object
    position*: ClayVector2
    state*: PointerDataInteractionState

var CLAY_LAYOUT_DEFAULT* {.importc: "CLAY_LAYOUT_DEFAULT".}: ClayLayoutConfig

proc minMemorySize*(): uint32 {.cdecl, importc: "Clay_MinMemorySize".}
proc createArenaWithCapacityAndMemory*(capacity: uint32; offset: pointer): ClayArena {.
    cdecl, importc: "Clay_CreateArenaWithCapacityAndMemory".}
proc setPointerState*(position: ClayVector2; pointerDown: bool): void {.cdecl,
    importc: "Clay_SetPointerState".}
proc initialize*(arena: ClayArena; layoutDimensions: ClayDimensions): void {.
    cdecl, importc: "Clay_Initialize".}
proc updateScrollContainers*(enableDragScrolling: bool;
                             scrollDelta: ClayVector2; deltaTime: cfloat): void {.
    cdecl, importc: "Clay_UpdateScrollContainers".}
proc setLayoutDimensions*(dimensions: ClayDimensions): void {.cdecl,
    importc: "Clay_SetLayoutDimensions".}
proc beginLayout*(): void {.cdecl, importc: "Clay_BeginLayout".}
proc endLayout*(): ClayRenderCommandArray {.cdecl, importc: "Clay_EndLayout".}
proc getElementId*(idString: ClayString): ClayElementId {.cdecl,
    importc: "Clay_GetElementId".}
proc getElementIdWithIndex*(idString: ClayString; index: uint32): ClayElementId {.
    cdecl, importc: "Clay_GetElementIdWithIndex".}
proc hovered*(): bool {.cdecl, importc: "Clay_Hovered".}
proc onHover*(onHoverFunction: proc (a0: ClayElementId; a1: ClayPointerdata;
                                     a2: pointer): void {.cdecl.};
              userData: pointer): void {.cdecl, importc: "Clay_OnHover".}
proc getScrollContainerData*(id: ClayElementId): ClayScrollContainerData {.
    cdecl, importc: "Clay_GetScrollContainerData".}
proc setMeasureTextFunction*(measureTextFunction: proc (a0: ptr ClayString;
    a1: ptr ClayTextElementConfig): ClayDimensions {.cdecl.}): void {.cdecl,
    importc: "Clay_SetMeasureTextFunction".}
proc setQueryScrollOffsetFunction*(queryScrollOffsetFunction: proc (a0: uint32): ClayVector2 {.
    cdecl.}): void {.cdecl, importc: "Clay_SetQueryScrollOffsetFunction".}
proc renderCommandArray_Get*(array_arg: ptr ClayRenderCommandArray; index: int32): ptr ClayRenderCommand {.
    cdecl, importc: "Clay_RenderCommandArray_Get".}
proc setDebugModeEnabled*(enabled: bool): void {.cdecl,
    importc: "Clay_SetDebugModeEnabled".}
proc setCullingEnabled*(enabled: bool): void {.cdecl,
    importc: "Clay_SetCullingEnabled".}
proc internal_OpenElement*(): void {.cdecl, importc: "Clay__OpenElement".}
proc internal_CloseElement*(): void {.cdecl, importc: "Clay__CloseElement".}
proc internal_StoreLayoutConfig*(config: ClayLayoutConfig): ptr ClayLayoutConfig {.
    cdecl, importc: "Clay__StoreLayoutConfig".}
proc internal_ElementPostConfiguration*(): void {.cdecl,
    importc: "Clay__ElementPostConfiguration".}
proc internal_AttachId*(id: ClayElementId): void {.cdecl,
    importc: "Clay__AttachId".}
proc internal_AttachLayoutConfig*(config: ptr ClayLayoutConfig): void {.cdecl,
    importc: "Clay__AttachLayoutConfig".}
proc internal_AttachElementConfig*(config: ClayElementConfigUnion;
                                   type_arg: ElementConfigType): void {.
    cdecl, importc: "Clay__AttachElementConfig".}
proc internal_StoreRectangleElementConfig*(config: ClayRectangleElementConfig): ptr ClayRectangleElementConfig {.
    cdecl, importc: "Clay__StoreRectangleElementConfig".}
proc internal_StoreTextElementConfig*(config: ClayTextElementConfig): ptr ClayTextElementConfig {.
    cdecl, importc: "Clay__StoreTextElementConfig".}
proc internal_StoreImageElementConfig*(config: ClayImageElementConfig): ptr ClayImageElementConfig {.
    cdecl, importc: "Clay__StoreImageElementConfig".}
proc internal_StoreFloatingElementConfig*(config: ClayFloatingElementConfig): ptr ClayFloatingElementConfig {.
    cdecl, importc: "Clay__StoreFloatingElementConfig".}
proc internal_StoreCustomElementConfig*(config: ClayCustomElementConfig): ptr ClayCustomElementConfig {.
    cdecl, importc: "Clay__StoreCustomElementConfig".}
proc internal_StoreScrollElementConfig*(config: ClayScrollElementConfig): ptr ClayScrollElementConfig {.
    cdecl, importc: "Clay__StoreScrollElementConfig".}
proc internal_StoreBorderElementConfig*(config: ClayBorderElementConfig): ptr ClayBorderElementConfig {.
    cdecl, importc: "Clay__StoreBorderElementConfig".}
proc internal_HashString*(key: ClayString; offset: uint32; seed: uint32): ClayElementId {.
    cdecl, importc: "Clay__HashString".}
proc intern*(key: ClayString): ClayString {.
    cdecl, importc: "Clay__InternString".}
proc internal_Noop*(): void {.cdecl, importc: "Clay__Noop".}
proc internal_OpenTextElement*(text: ClayString;
                               textConfig: ptr ClayTextElementConfig): void {.
    cdecl, importc: "Clay__OpenTextElement".}
var Clay_debugViewHighlightColor* {.importc: "Clay__debugViewHighlightColor".}: ClayColor
var Clay_debugViewWidth* {.importc: "Clay__debugViewWidth".}: uint32
var Clay_debugMaxElementsLatch* {.importc: "Clay__debugMaxElementsLatch".}: bool

func clayColor*(r, g, b: float32, a: float32 = 1): ClayColor =
  ClayColor(
    r: (r * 255).cfloat,
    g: (g * 255).cfloat,
    b: (b * 255).cfloat,
    a: (a * 255).cfloat,
  )

func cornerRadius*(topLeft, topRight, bottomLeft, bottomRight: float): ClayCornerRadius =
  ClayCornerRadius(
    topLeft: topLeft.cfloat,
    topRight: topRight.cfloat,
    bottomLeft: bottomLeft.cfloat,
    bottomRight: bottomRight.cfloat,
  )

template cs*(str: string): ClayString =
  ClayString(length: str.len.cint, chars: str.cstring)

proc `$`*(str: ClayString): string =
  result = newStringUninit(str.length.int)
  for i in 0..<str.length.int:
    result[i] = str.chars[i]

macro UI*(args: varargs[untyped]): untyped =
  # defer:
  #   echo result.repr

  var configs = nnkStmtList.newTree()
  var children = nnkStmtList.newTree()

  proc parseArgsInto(into: var NimNode, arg: NimNode) =
    if arg.len == 2 and arg[1].kind != nnkExprEqExpr:
      into = arg[1]
    else:
      for k in 1..<arg.len:
        let prop = arg[k]
        into.add(nnkExprColonExpr.newTree(prop[0], prop[1]))

  for i, arg in args:
    case arg.kind
    of nnkCall:
      let fun = arg[0].repr
      case fun
      of "rectangle":
        var rectElementConfig = nnkObjConstr.newTree(ident"ClayRectangleElementConfig")
        rectElementConfig.parseArgsInto(arg)
        let config = genAst(rectElementConfig):
          internal_AttachElementConfig(ClayElementConfigUnion(rectangleElementConfig: internal_StoreRectangleElementConfig(rectElementConfig)), ElementConfigType.Rectangle)
        configs.add config

      of "layout":
        var layoutConfig = nnkObjConstr.newTree(ident"ClayLayoutConfig")
        layoutConfig.parseArgsInto(arg)
        let config = genAst(layoutConfig):
          internal_AttachLayoutConfig(internal_StoreLayoutConfig(layoutConfig))
        configs.add config

      # todo: other types

    of nnkStmtList:
      if i == args.len - 1:
        children = arg
        break

    else:
      error("Invalid argument to UI", arg)

  result = genAst(configs, children):
    block:
      internal_OpenElement()
      defer:
        internal_CloseElement()
      block:
        configs
        internal_ElementPostConfiguration()
      children

macro clayText*(str: untyped, args: varargs[untyped]): untyped =
  var call = nnkCall.newTree(ident"internal_OpenTextElement")
  let strConv = genAst(str):
    when typeof(str) is string:
      intern(cs(str))
    else:
      str
  call.add(strConv)

  proc parseArgsInto(into: var NimNode, arg: NimNode) =
    if arg.len == 1 and arg[0].kind != nnkExprEqExpr:
      into = arg[0]
    else:
      for k in 0..<arg.len:
        let prop = arg[k]
        into.add(nnkExprColonExpr.newTree(prop[0], prop[1]))

  var textConfig = nnkObjConstr.newTree(ident"ClayTextElementConfig")
  textConfig.parseArgsInto(args)
  let configPtr = genAst(textConfig):
    internal_StoreTextElementConfig(textConfig)
  call.add(configPtr)

  return call
