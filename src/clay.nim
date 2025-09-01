import std/[macros, genasts, strformat, sequtils]

{.compile: "clay.c".}

# Macro Used to Create Wrapper, Slice and Array Procs
proc WrapperType[T](type_arg: T): string =
  return fmt"Clay{type_arg}Wrapper"

macro WrapperStruct(type_arg: untyped): untyped =
  let t = WrapperType(type_arg)
  result = genAst(t):
    type t* = object
      wrapped*: t

template DefineArray(typeName, arrayName: untyped): untyped =
  type `arrayName` = ref object
    capacity: uint32
    length: uint32
    internalArray: seq[typeName]

  type `arrayName Slice` = ref object
    length: uint32
    internalArray: seq[typeName]

macro DefineFunctions(typeName: untyped, arrayName: untyped): untyped =
  let
    t = `typeName`
    a = `arrayName`

  template DefineProcs(typeName, arrayName: untyped): untyped =
    proc `arrayName Init`[T](capacity: uint32): arrayName =
      var a: arrayName
      a.internalArray = newSeqOfCap[T](capacity)
      a.capacity = capacity
      a.length = 0
      return a

    proc `arrayName AllocateArena`[T](capacity: uint32, arena: seq[T]): arrayName =
      var a = `arrayName Init`[T](capacity)
      a.internalArray.concat(arena)
      return a

    proc `arrayName Get`(array: arrayName, index: uint32): typeName =
      return array.internalArray[index]

    proc `arrayName GetValue`(array: arrayName, index: uint32): typeName =
      return `arrayName Get`(array, index)

    proc `arrayName Add`(array: arrayName, item: typeName): arrayName =
      var a = array
      a.internalArray.add(item)
      return a

    proc `arrayName RemoveSwapback`(array: arrayName, index: uint32): arrayName =
      var a = array
      a.internalArray.del(index)
      return a

    proc `arrayName Set`(array: arrayName, index: uint32, value: typeName): arrayName =
      var a = array
      a.internalArray[index] = value
      return a

  result = genAst(t, a):
    DefineArray(t, a)
    DefineProcs(t, a)

DefineArray(bool, ClayBoolArray)
DefineArray(int32, ClayInt32Array)
DefineArray(char, ClayCharArray)

type
  ErrorType* {.size: sizeof(cuint).} = enum
    TextMeasurementFunctionNotProvided = 0,
    ArenaCapacityExceeded = 1,
    ElementsCapacityExceeded = 2,
    TextMeasurementCapacityExceeeded = 3,
    DuplicateId = 4,
    FloatingContainerParentNotFound = 5,
    PercentageOverOne = 6,
    InternalError = 7

  ElementConfigType* {.size: sizeof(cuint).} = enum
    None = 0,
    Border = 1,
    Floating = 2,
    Clip = 3,
    Aspect = 4,
    Image = 5,
    Text = 6,
    Custom = 7,
    Shared = 8

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

  TextElementConfigWrapMode* {.size: sizeof(cuint).} = enum
    Words = 0,
    Newlines = 1,
    None = 2

  TextAlignment* {.size: sizeof(cuint).} = enum
    Left
    Right
    Center

  PointerCaptureMode* {.size: sizeof(cuint).} = enum
    Capture = 0,
    Passthrough = 1

  PointerDataInteractionState* {.size: sizeof(cuint).} = enum
    PressedThisFrame = 0,
    Pressed = 1,
    ReleasedThisFrame = 2,
    Released = 3

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

  FloatingAttachToElement* {.size: sizeof(cuint).} = enum
    None = 0,
    Parent = 1,
    ElementWithId = 2,
    Root = 3

  FloatingClipToElement* {.size: sizeof(cuint).} = enum
    None = 0,
    AttachedParent = 1

  RenderCommandType* {.size: sizeof(cuint).} = enum
    None = 0,
    Rectangle = 1,
    Border = 2,
    Text = 3,
    Image = 4,
    ScissorStart = 5,
    ScissorEnd = 6,
    Custom = 7

type
  ClayString* {.pure, inheritable, bycopy.} = object
    isStaticallyAllocated*: bool
    length*: cint
    chars*: cstring

DefineArray(ClayString, ClayStringArray)

type
  ClayStringSlice* {.pure, inheritable, bycopy.} = object
    length*: uint32
    chars*: cstring
    baseChars*: cstring
  ClayBooleanWarnings* {.pure, inheritable, bycopy.} = object
    maxElementsExceeded*: bool
    maxRenderCommandsExceeded*: bool
    maxTextMeasureCacheExceeded*: bool
    txtMeasurementFunctionNotSet*: bool
  ClayWarning* {.pure, inheritable, bycopy.} = object
    baseMessage*: ClayString
    dynamicMessage*: ClayString

DefineArray(ClayWarning, ClayWarningArray)

type
  ClayArena* {.pure, inheritable, bycopy.} = object
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

DefineFunctions(ClayElementId, ClayElementIdArray)

type
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
    minMax*: ClaySizingMinMax
    percent*: float32
  ClaySizingAxis* {.pure, inheritable, bycopy.} = object
    union*: ClaySizingAxisUnion
    typ*: SizingType
  ClaySizing* {.pure, inheritable, bycopy.} = object
    width*: ClaySizingAxis
    height*: ClaySizingAxis
  ClayPadding* {.pure, inheritable, bycopy.} = object
    left*: uint16
    right*: uint16
    top*: uint16
    bottom*: uint16
  ClaySharedElementConfig* {.pure, inheritable, bycopy.} = object
    backgroundColor*: ClayColor
    cornerRadius*: ClayCornerRadius
    userData*: pointer

DefineArray(ClaySharedElementConfig, ClaySharedElementConfigArray)

type
  ClayLayoutConfig* {.pure, inheritable, bycopy.} = object
    sizing*: ClaySizing
    padding*: ClayPadding
    childGap*: uint16
    childAlignment*: ClayChildAlignment
    layoutDirection*: LayoutDirection

DefineArray(ClayLayoutConfig, ClayLayoutConfigArray)

type
  ClayTextElementConfig* {.pure, inheritable, bycopy.} = object
    userData*: pointer
    textColor*: ClayColor
    fontId*: uint16
    fontSize*: uint16
    letterSpacing*: uint16
    lineHeight*: uint16
    wrapMode*: TextElementConfigWrapMode
    textAlignment*: TextAlignment

DefineArray(ClayTextElementConfig, ClayTextElementConfigArray)

type
  ClayAspectRatioElementConfig* {.pure, inheritable, bycopy.} = object
    aspectRatio*: float32

DefineArray(ClayAspectRatioElementConfig, ClayAspectRatioElementConfigArray)

type
  ClayImageElementConfig* {.pure, inheritable, bycopy.} = object
    imageData*: pointer

DefineArray(ClayImageElementConfig, ClayImageElementConfigArray)

type
  ClayFloatingAttachPoints* {.pure, inheritable, bycopy.} = object
    element*: FloatingAttachPointType
    parent*: FloatingAttachPointType
  ClayFloatingElementConfig* {.pure, inheritable, bycopy.} = object
    offset*: ClayVector2
    expand*: ClayDimensions
    parentId*: uint32
    zIndex*: uint16
    attachPoints*: ClayFloatingAttachPoints
    pointerCaptureMode*: PointerCaptureMode
    attachTo*: FloatingAttachToElement
    clipTo*: FloatingClipToElement

DefineArray(ClayFloatingElementConfig, ClayFloatingElementConfigArray)

type
  ClayCustomElementConfig* {.pure, inheritable, bycopy.} = object
    customData*: pointer

DefineArray(ClayCustomElementConfig, ClayCustomElementConfigArray)

type
  ClayClipElementConfig* {.pure, inheritable, bycopy.} = object
    horizontal*: bool
    vertical*: bool
    childOffset*: ClayVector2

DefineArray(ClayClipElementConfig, ClayClipElementConfigArray)

type
  ClayBorderWidth* {.pure, inheritable, bycopy.} = object
    left*: uint16
    right*: uint16
    top*: uint16
    bottom*: uint16
    betweenChildren*: uint16
  ClayBorderElementConfig* {.pure, inheritable, bycopy.} = object
    color*: ClayColor
    width*: ClayBorderWidth

DefineArray(ClayBorderElementConfig, ClayBorderElementConfigArray)

type
  ClayErrorData* {.pure, inheritable, bycopy.} = object
    errorType*: ErrorType
    errorText*: ClayString
    userData*: pointer
  ClayErrorHandler* {.pure, inheritable, bycopy.} = object
    errorHandlerCb*: proc(errorText: ClayErrorData)
    userData*: pointer
  ClayTextRenderData* {.pure, inheritable, bycopy.} = object
    stringContents*: ClayStringSlice
    textColor*: ClayColor
    fontId*: uint16
    fontSize*: uint16
    letterSpacing*: uint16
    lineHeight*: uint16
  ClayRectangleRenderData* {.pure, inheritable, bycopy.} = object
    backgroundColor*: ClayColor
    cornerRadius*: ClayCornerRadius
  ClayImageRenderData* {.pure, inheritable, bycopy.} = object
    backgroundColor*: ClayColor
    cornerRadius*: ClayCornerRadius
    imageData*: pointer
  ClayCustomRenderData* {.pure, inheritable, bycopy.} = object
    backgroundColor*: ClayColor
    cornerRadius*: ClayCornerRadius
    customData*: pointer
  ClayClipRenderData* {.pure, inheritable, bycopy.} = object
    horizontal*: bool
    vertical*: bool
  ClayBorderRenderData* {.pure, inheritable, bycopy.} = object
    color*: ClayColor
    cornerRadius*: ClayCornerRadius
    width*: ClayBorderWidth
  ClayScrollContainerData* {.pure, inheritable, bycopy.} = object
    scrollPosition*: ClayVector2
    scrollContainerDimensions*: ClayDimensions
    contentDimensions*: ClayDimensions
    config*: ClayClipElementConfig
    found*: bool
  ClayElementData* {.pure, inheritable, bycopy.} = object
    boundingBox*: ClayBoundingBox
    found*: bool
  ClayRenderDataUnion* {.pure, inheritable, bycopy.} = object
    rectangle*: ClayRectangleRenderData
    text*: ClayTextRenderData
    image*: ClayImageRenderData
    custom*: ClayCustomRenderData
    border*: ClayBorderRenderData
    clip*: ClayClipRenderData
  ClayRenderCommand* {.pure, inheritable, bycopy.} = object
    boundingBox*: ClayBoundingBox
    renderData*: ClayRenderDataUnion
    userData*: pointer
    id*: uint32
    zIndex*: uint16
    commandType*: RenderCommandType

DefineFunctions(ClayRenderCommand, ClayRenderCommandArray)

type
  ClayPointerData* {.pure, inheritable, bycopy.} = object
    position*: ClayVector2
    state*: PointerDataInteractionState
  ClayElementDeclaration* {.pure, inheritable, bycopy.} = object
    id*: ClayElementId
    layout*: ClayLayoutConfig
    backgroundColor*: ClayColor
    cornerRadius*: ClayCornerRadius
    aspectRatio*: ClayAspectRatioElementConfig
    image*: ClayImageElementConfig
    floating*: ClayFloatingElementConfig
    custom*: ClayCustomElementConfig
    clip*: ClayClipElementConfig
    border*: ClayBorderElementConfig
    userData*: pointer
  ClayElementConfigUnion* {.union, bycopy.} = object
    textElementConfig*: ptr ClayTextElementConfig
    aspectRatioElementConfig*: ptr ClayAspectRatioElementConfig
    imageElementConfig*: ptr ClayImageElementConfig
    floatingElementConfig*: ptr ClayFloatingElementConfig
    customElementConfig*: ptr ClayCustomElementConfig
    clipElementConfig*: ptr ClayClipElementConfig
    borderElementConfig*: ptr ClayBorderElementConfig
    sharedElementConfig*: ptr ClaySharedElementConfig
  ClayElementConfig* {.pure, inheritable, bycopy.} = object
    type_arg*: ElementConfigType
    config*: ClayElementConfigUnion

DefineArray(ClayElementConfig, ClayElementConfigArray)

type
  ClayWrappedTextLine* {.pure, inheritable, bycopy.} = object
    dimensions*: ClayDimensions
    line*: ClayString

DefineArray(ClayWrappedTextLine, ClayWrappedTextLineArray)

type
  ClayLayoutElementChildren* {.pure, inheritable, bycopy.} = object
    elements*: uint32
    length*: uint16
type
  ClayTextElementData* {.pure, inheritable, bycopy.} = object
    text*: ClayString
    preferredDimensions*: ClayDimensions
    elementIndex*: uint32
    wrappedLines*: ClayWrappedTextLineArraySlice

DefineArray(ClayTextElementData, ClayTextElementDataArray)

type
  ClayLayoutElementUnion* {.union, bycopy.} = object
    children*: ClayLayoutElementChildren
    textElementData*: ClayTextElementData
  ClayLayoutElement* {.pure, inheritable, bycopy.} = object
    childrenOrTextContent*: ClayLayoutElementUnion
    dimensions*: ClayDimensions
    minDimensions*: ClayDimensions
    layoutConfig*: ClayLayoutConfig
    elementConfigs*: ClayElementConfigArraySlice
    id*: uint32

DefineFunctions(ClayLayoutElement, ClayLayoutElementArray)

type
  ClayLayoutElementTreeNode* {.pure, inheritable, bycopy.} = object
    layoutElement*: ClayLayoutElement
    position*: ClayVector2
    nextChildOffset*: ClayVector2

DefineArray(ClayLayoutElementTreeNode, ClayLayoutElementTreeNodeArray)

type
  ClayScrollContainerDataInternal* {.pure, inheritable, bycopy.} = object
    layoutElement*: ClayLayoutElement
    boundingBox*: ClayBoundingBox
    contentSize*: ClayDimensions
    scrollOrigin*: ClayVector2
    scrollMomentum*: ClayVector2
    scrollPosition*: ClayVector2
    previousDelta*: ClayVector2
    momentumTime*: float32
    elementId*: uint32
    openThisFrame*: bool
    pointerScrollActive*: bool

DefineArray(ClayScrollContainerDataInternal, ClayScrollContainerDataInternalArray)

type
  ClayDebugElementData* {.pure, inheritable, bycopy.} = object
    collision*: bool
    collapsed*: bool

DefineArray(ClayDebugElementData, ClayDebugElementDataArray)

type
  ClayLayoutElementHashMapItem* {.pure, inheritable, bycopy.} = object
    boundingBox*: ClayBoundingBox
    elementId*: ClayElementId
    layoutElement*: ClayLayoutElement
    onHoverFunction*: proc(elementId: ClayElementId, pointerInfo: ClayPointerData, userData: pointer)
    hoverFunctionUserData*: pointer
    nextIndex*: uint32
    generation*: uint32
    idAlias*: uint32
    debugData*: ClayDebugElementData

DefineArray(ClayLayoutElementHashMapItem, ClayLayoutElementHashMapItemArray)

type
  ClayMeasuredWord* {.pure, inheritable, bycopy.} = object
    startOffset*: uint32
    length*: uint32
    width*: float32
    next*: uint32

DefineArray(ClayMeasuredWord, ClayMeasuredWordArray)

type
  ClayMeasureTextCacheItem* {.pure, inheritable, bycopy.} = object
    unwrappedDimensions*: ClayDimensions
    measuredWordsStartIndex*: uint32
    minWidth*: float32
    containsNewLines*: bool
    id*: uint32
    nextIndex*: uint32
    generation*: uint32

DefineArray(ClayMeasureTextCacheItem, ClayMeasureTextCacheItemArray)

type
  ClayLayoutElementTreeRoot* {.pure, inheritable, bycopy.} = object
    layoutElementIndex*: uint32
    parentId*: uint32
    clipElementId*: uint32
    zIndex*: uint16
    pointerOffset*: ClayVector2

DefineArray(ClayLayoutElementTreeRoot, ClayLayoutElementTreeRootArray)

type
  ClayDebugElementConfigTypeLabelConfig* {.pure, inheritable, bycopy.} = object
    label*: ClayString
    color*: ClayColor
  ClayRenderDebugLayoutData* {.pure, inheritable, bycopy.} = object
    rowCount*: uint32
    selectedElementRowIndex*: uint32
  ClayContext* {.pure, inheritable, bycopy.} = object
    maxElementCount*: uint32
    maxMeasureTextCacheWordCount*: uint32
    warningsEnabled*: bool
    errorHandler*: ClayErrorHandler
    booleanWarnings*: ClayBooleanWarnings
    warnings*: ClayWarningArray
    pointerInfo*: ClayPointerData
    layoutDimensions*: ClayDimensions
    dynamicElementIndexBaseHash*: ClayElementId
    dynamicElementIndex*: uint32
    debugModeEnabled*: bool
    disableCulling*: bool
    externalScrollHandlingEnabled*: bool
    debugSelectedElementId*: uint32
    generation*: uint32
    arenaResetOffset*: uint64
    measureTextUserData*: pointer
    queryScrollOffsetUserData*: pointer
    internalArena*: ClayArena
    layoutElements*: ClayLayoutElementArray
    renderCommands*: ClayRenderCommandArray
    openLayoutElementStack*: ClayInt32Array
    layoutElementChildren*: ClayInt32Array
    layoutElementChildrenBuffer*: ClayInt32Array
    textElementData*: ClayTextElementDataArray
    aspectRatioElementIndexes*: ClayInt32Array
    reusableElementIndexBuffer*: ClayInt32Array
    layoutElementClipElementIds*: ClayInt32Array
    layoutConfigs*: ClayLayoutConfigArray
    elementConfigs*: ClayElementConfigArray
    textElementConfigs*: ClayTextElementConfigArray
    aspectRatioElementConfigs*: ClayAspectRatioElementConfigArray
    imageElementConfigs*: ClayImageElementConfigArray
    floatingElementConfigs*: ClayFloatingElementConfigArray
    clipElementConfigs*: ClayClipElementConfigArray
    customElementConfigs*: ClayCustomElementConfigArray
    borderElementConfigs*: ClayBorderElementConfigArray
    sharedElementConfigs*: ClaySharedElementConfigArray
    layoutElementIdStrings*: ClayStringArray
    wrappedTextLines*:ClayWrappedTextLineArray
    layoutElementTreeNodeArray1*: ClayLayoutElementTreeNodeArray
    layoutElementTreeRoots*: ClayLayoutElementTreeRootArray
    layoutElementsHashMapInternal*: ClayLayoutElementHashMapItemArray
    layoutElementsHashMap*: ClayInt32Array
    measureTextHashMapInternal*: ClayMeasureTextCacheItemArray
    measureTextHashMapInternalFreeList*: ClayInt32Array
    measureTextHashMap*: ClayInt32Array
    measuredWords*: ClayMeasuredWordArray
    measuredWordsFreeList*: ClayInt32Array
    openClipElementStack*: ClayInt32Array
    pointerOverIds*: ClayElementIdArray
    scrollContainerDatas*: ClayScrollContainerDataInternalArray
    treeNodeVisited*: ClayBoolArray
    dynamicStringData*: ClayCharArray
    debugElementData*: ClayDebugElementDataArray

var CLAY_LAYOUT_DEFAULT* {.importc: "CLAY_LAYOUT_DEFAULT".}: ClayLayoutConfig

proc internal_contextAllocateArena*(arena: ptr ClayArena): ClayContext {.cdecl, importc: "Clay__Context_Allocate_Arena".}
proc internal_writeStringToCharBuffer*(buffer: ptr ClayCharArray, str: ClayString): ClayString {.cdecl, importc: "Clay__WriteStringToCharBuffer".}
proc internal_getOpenLayoutElement*(): ClayLayoutElement {.cdecl, importc: "Clay__GetOpenLayoutElement".}
proc internal_getParentElementId*(): uint32 {.cdecl, importc: "Clay__GetParentElementId".}
proc internal_OpenElement*(): void {.cdecl, importc: "Clay__OpenElement".}
proc internal_CloseElement*(): void {.cdecl, importc: "Clay__CloseElement".}
proc internal_StoreLayoutConfig*(config: ClayLayoutConfig): ptr ClayLayoutConfig {.
    cdecl, importc: "Clay__StoreLayoutConfig".}
proc internal_StoreTextElementConfig*(config: ClayTextElementConfig): ptr ClayTextElementConfig {.
    cdecl, importc: "Clay__StoreTextElementConfig".}
proc internal_StoreImageElementConfig*(config: ClayImageElementConfig): ptr ClayImageElementConfig {.
    cdecl, importc: "Clay__StoreImageElementConfig".}
proc internal_StoreFloatingElementConfig*(config: ClayFloatingElementConfig): ptr ClayFloatingElementConfig {.
    cdecl, importc: "Clay__StoreFloatingElementConfig".}
proc internal_StoreCustomElementConfig*(config: ClayCustomElementConfig): ptr ClayCustomElementConfig {.
    cdecl, importc: "Clay__StoreCustomElementConfig".}
proc internal_StoreClipElementConfig*(config: ClayClipElementConfig): ptr ClayClipElementConfig {.
    cdecl, importc: "Clay__StoreClipElementConfig".}
proc internal_StoreBorderElementConfig*(config: ClayBorderElementConfig): ptr ClayBorderElementConfig {.
    cdecl, importc: "Clay__StoreBorderElementConfig".}
proc internal_StoreSharedElementConfig*(config: ClaySharedElementConfig): ptr ClaySharedElementConfig {.
    cdecl, importc: "Clay__StoreSharedElementConfig".}
proc internal_AttachElementConfig*(config: ClayElementConfigUnion,
                                   type_arg: ElementConfigType): void {.
    cdecl, importc: "Clay__AttachElementConfig".}
proc internal_FindElementConfigWithType*(element: ptr ClayLayoutElement, type_arg: ElementConfigType): ClayElementConfigUnion {.
    cdecl, importc: "Clay__FindElementConfigWithType".}
proc internal_HashNumber*(offset: uint32, seed: uint32): ClayElementId {.
    cdecl, importc: "Clay__HashNumber".}
proc internal_HashString*(key: ClayString, offset: uint32, seed: uint32): ClayElementId {.
    cdecl, importc: "Clay__HashString".}
proc internal_HashStringWithOffset*(key: ClayString, offset: uint32, seed: uint32): ClayElementId {.
    cdecl, importc: "Clay__HashStringWithOffset".}
proc internal_HashData*(data: uint8, length: uint32): uint64 {.cdecl, importc: "Clay__HashData".}
proc internal_HashStringContentsWithConfig*(text: ptr ClayString, config: ptr ClayTextElementConfig): uint32 {.
    cdecl, importc: "Clay__HashStringContentsWithConfig".}
proc internal_AddMeasuredWord*(word: ClayMeasuredWord, prevousWord: ptr ClayMeasuredWord): ClayMeasuredWord {.
    cdecl, importc: "Clay__AddMeasuredWord".}
proc internal_MeasureTextCached*(text: ptr ClayString, config: ptr ClayTextElementConfig): ClayMeasureTextCacheItem {.
    cdecl, importc: "Clay__MeasureTextCached".}
proc internal_PointIsInsideRect*(point: ClayVector2, rect: ClayBoundingBox): bool {.cdecl, importc: "Clay__PointIsInsideRect".}
proc internal_AddHashMapItem*(elementId: ClayElementId, layoutElement: ptr ClayLayoutElement, idAlias: uint32): ptr ClayLayoutElementHashMapItem {.
    cdecl, importc: "Clay__AddHashMapItem".}
proc internal_GetHashMapItem*(id: uint32): ptr ClayLayoutElementHashMapItem {.
    cdecl, importc: "Clay__GetHashMapItem".}
proc internal_GenerateIdForAnonymousElement*(openLayoutElement: ptr ClayLayoutElement): ClayElementId {.cdecl,
    importc: "Clay__GenerateIdForAnonymousElement".}
proc internal_ElementHasConfig*(layoutElement: ptr ClayLayoutElement, type_arg: ElementConfigType): bool {.cdecl, importc: "Clay__ElementHasConfig".}
proc internal_UpdateAspectRatioBox*(layoutElement: ptr ClayLayoutElement): void {.cdecl, importc: "Clay__UpdateAspectRatioBox".}
proc internal_MemCmp*(s1: cstring, s2: cstring, length: uint32): bool {.cdecl, importc: "Clay__MemCmp".}
proc internal_OpenTextElement*(text: ClayString,
                               textConfig: ptr ClayTextElementConfig): void {.
    cdecl, importc: "Clay__OpenTextElement".}
proc internal_AttachId*(elementId: ClayElementId): ClayElementId {.cdecl, importc: "Clay__AttachId".}
proc internal_ConfigureOpenElementPtr*(declaration: ptr ClayElementDeclaration): void {.cdecl, importc: "Clay__ConfigureOpenElementPtr".}
proc internal_ConfigureOpenElement*(declaration: ClayElementDeclaration): void {.cdecl, importc: "Clay__ConfigureOpenElement".}
proc internal_InitializeEphemeralMemory*(context: ptr ClayContext): void {.cdecl, importc: "Clay__InitializeEphemeralMemory".}
proc internal_InitializePersistentMemory*(context: ptr ClayContext): void {.cdecl, importc: "Clay__InitializePersistentMemory".}
proc internal_FloatEqual*(left: cfloat, right: cfloat): bool {.cdecl, importc: "Clay__FloatEqual".}
proc internal_SizeContainersAlongAxis*(xAxis: bool): void {.cdecl, importc: "Clay__SizeContainersAlongAxis".}
proc internal_IntToString*(integer: cint): ClayString {.cdecl, importc: "Clay__IntToString".}
proc internal_AddRenderCommand*(renderCommand: ClayRenderCommand): void {.cdecl, importc: "Clay__AddRenderCommand".}
proc internal_ElementIsOffscreen*(boundingBox: ptr ClayBoundingBox): bool {.cdecl, importc: "Clay__ElementIsOffscreen".}
proc internal_CalculateFinalLayout*(): void {.cdecl, importc: "Clay__CalculateFinalLayout".}
proc internal_DebugGetElementConfigTypeLabel*(type_arg: ElementConfigType): ClayDebugElementConfigTypeLabelConfig {.
    cdecl, importc: "Clay__DebugGetElementConfigTypeLabel".}
proc internal_RenderDebugLayoutElementsList*(initialRootsLength: cint, highlightedRowIndex: cint): ClayRenderDebugLayoutData {.
    cdecl, importc: "Clay__RenderDebugLayoutElementsList".}
proc internal_RenderDebugLayoutSizing*(sizing: ClaySizingAxis, infoTextConfig: ptr ClayTextElementConfig): void {.
    cdecl, importc: "Clay__RenderDebugLayoutSizing".}
proc internal_RenderDebugViewElementConfigHeader*(elementId: ClayString, type_arg: ElementConfigType): void {.
    cdecl, importc: "Clay__RenderDebugViewElementConfigHeader".}
proc internal_RenderDebugViewColor*(color: ClayColor, textConfig: ptr ClayTextElementConfig): void {.
    cdecl, importc: "Clay__RenderDebugViewColor".}
proc internal_RenderDebugViewCornerRadius*(cornerRadius: ClayCornerRadius, textConfig: ptr ClayTextElementConfig): void {.
    cdecl, importc: "Clay__RenderDebugViewCornerRadius".}
proc internal_HandleDebugViewCloseButtonInteraction*(elementId: ClayElementId, pointerInfo: ClayPointerData, userData: ptr cint): void {.
    cdecl, importc: "Clay__HandleDebugViewCloseButtonInteraction".}
proc internal_RenderDebugView*(): void {.cdecl, importc: "Clay__RenderDebugView".}
proc internal_WarningArrayAllocateArena*(capacity: cint, arena: ptr ClayArena): ClayWarningArray {.cdecl, importc: "Clay__WarningArray_Allocate_Arena".}
proc internal_WarningArrayAdd*(array: ptr ClayWarningArray, item: ClayWarning): ClayWarning {.cdecl, importc: "Clay__WarningArray_Add".}
proc internal_ArrayAllocateArena*(capacity: cint, itemSize: uint32, arena: ptr ClayArena): pointer {.cdecl, importc: "Clay__Array_Allocate_Arena".}
proc internal_ArrayRangeCheck*(index: cint, length: cint): bool {.cdecl, importc: "Clay__Array_RangeCheck".}
proc internal_ArrayAddCapacityCheck*(length: cint, capacity: cint): bool {.cdecl, importc: "Clay__Array_AddCapacityCheck".}
# Clay Public API
proc minMemorySize*(): uint32 {.cdecl, importc: "Clay_MinMemorySize".}
proc createArenaWithCapacityAndMemory*(capacity: uint32, memory: pointer): ClayArena {.
    cdecl, importc: "Clay_CreateArenaWithCapacityAndMemory".}
proc setMeasureTextFunction*(measureTextFunction: proc (a0: ptr ClayString,
    a1: ptr ClayTextElementConfig): ClayDimensions {.cdecl.}): void {.cdecl,
    importc: "Clay_SetMeasureTextFunction".}
proc setQueryScrollOffsetFunction*(queryScrollOffsetFunction: proc (a0: uint32): ClayVector2 {.
    cdecl.}): void {.cdecl, importc: "Clay_SetQueryScrollOffsetFunction".}
proc setLayoutDimensions*(dimensions: ClayDimensions): void {.cdecl,
    importc: "Clay_SetLayoutDimensions".}
proc setPointerState*(position: ClayVector2, isPointerDown: bool): void {.cdecl,
    importc: "Clay_SetPointerState".}
proc initialize*(arena: ClayArena, layoutDimensions: ClayDimensions, errorHandler: ClayErrorHandler): ptr ClayContext {.
    cdecl, importc: "Clay_Initialize".}
proc getCurrentContext*(): ptr ClayContext {.cdecl, importc: "Clay_GetCurrentContext".}
proc setCurrentContext*(context: ptr ClayContext) {.cdecl, importc: "Clay_SetCurrentContext".}
proc getScrollOffset*(): ClayVector2 {.cdecl, importc: "Clay_GetScrollOffset".}
proc updateScrollContainers*(enableDragScrolling: bool,
                             scrollDelta: ClayVector2, deltaTime: cfloat): void {.
    cdecl, importc: "Clay_UpdateScrollContainers".}
proc beginLayout*(): void {.cdecl, importc: "Clay_BeginLayout".}
proc endLayout*(): ClayRenderCommandArray {.cdecl, importc: "Clay_EndLayout".}
proc getElementId*(idString: ClayString): ClayElementId {.cdecl,
    importc: "Clay_GetElementId".}
proc getElementIdWithIndex*(idString: ClayString, index: uint32): ClayElementId {.
    cdecl, importc: "Clay_GetElementIdWithIndex".}
proc hovered*(): bool {.cdecl, importc: "Clay_Hovered".}
proc onHover*(onHoverFunction: proc (a0: ClayElementId, a1: ClayPointerData,
                                     a2: pointer): void {.cdecl.},
              userData: pointer): void {.cdecl, importc: "Clay_OnHover".}
proc pointerOver*(elementId: ClayElementId): bool {.cdecl, importc: "Clay_PointerOver".}
proc getScrollContainerData*(id: ClayElementId): ClayScrollContainerData {.
    cdecl, importc: "Clay_GetScrollContainerData".}
proc getElementData*(id: ClayElementId): ClayElementData {.
    cdecl, importc: "Clay_GetElementData".}
proc setDebugModeEnabled*(enabled: bool): void {.cdecl,
    importc: "Clay_SetDebugModeEnabled".}
proc isDebugModeEnabled*(): bool {.cdecl,
    importc: "Clay_IsDebugModeEnabled".}
proc setCullingEnabled*(enabled: bool): void {.cdecl,
    importc: "Clay_SetCullingEnabled".}
proc setExternalScrollHandlingEnabled*(enabled: bool): void {.cdecl, importc: "Clay_SetExternalScrollHandlingEnabled".}
proc getMaxElementCount*(): cint {.cdecl, importc: "Clay_GetMaxElementCount".}
proc setMaxElementCount*(maxElementCount: cint): void {.cdecl, importc: "Clay_SetMaxElementCount".}
proc getMaxMeasureTextCacheWordCount*(): cint {.cdecl, importc: "Clay_GetMaxMeasureTextCacheWordCount".}
proc setMaxMeasureTextCacheWordCount*(maxMeasureTextCacheWordCount: cint): void {.cdecl,
    importc: "Clay_SetMaxMeasureTextCacheWordCount".}
proc resetMeasureTextCache*(): void {.cdecl, importc: "Clay_ResetMeasureTextCache".}

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

proc `$`*(str: ClayString): string =
  result = newStringUninit(str.length.int)
  for i in 0..<str.length.int:
    result[i] = str.chars[i]

macro UI*(args: varargs[untyped]): untyped =
  # defer:
  #   echo result.repr

  var children = nnkStmtList.newTree()

  var elementDecl = nnkObjConstr.newTree(ident"ClayElementDeclaration")
  for k in 0..<args.len:
    let arg = args[k]
    if k == args.len - 1 and arg.kind == nnkStmtList:
      children = arg
    else:
      elementDecl.add(nnkExprColonExpr.newTree(arg[0], arg[1]))

  result = genAst(children, elementDecl):
    try:
      internal_OpenElement()
      internal_ConfigureOpenElement(elementDecl)
      children
    finally:
      internal_CloseElement()

converter toUncheckedArray*[T](arr: openArray[T]): ptr UncheckedArray[T] =
  if arr.len > 0:
    cast[ptr UncheckedArray[T]](arr[0].addr)
  else:
    nil

macro clayText*(str: openArray[char], args: varargs[untyped]): untyped =
  defer:
    echo result.repr

  var call = nnkCall.newTree(ident"internal_OpenTextElement")
  let strConv = if str.kind == nnkStrLit:
    genAst(str):
      ClayString(length: str.len.cint, chars: cast[ptr UncheckedArray[char]](str.cstring))
  else:
    genAst(str):
      ClayString(length: str.len.cint, chars: str.toUncheckedArray)
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

iterator items*(self: ClayRenderCommandArray): ptr ClayRenderCommand =
  for i in 0..<self.length.int:
    yield self.internalArray[i].addr

template toOpenArray*(s: ClayStringSlice): openArray[char] =
  s.chars.toOpenArray(0, s.length - 1)
