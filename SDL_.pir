
=head1 NAME

SDL - Parrot extension for SDL bindings

=head1 SYNOPSIS

None.

You probably shouldn't use this library directly, unless you're writing your
own wrappers around the SDL NCI code or if you're calling the NCI functions
directly.

In that case, I'm perfectly happy saying "Hey buddy, you're on your own!"

=head1 DESCRIPTION

This is the library that contains all of the actual NCI bindings and Parrot
data structure definitions to work with SDL from Parrot.  Normal people, run
away to L<SDL::App> right now instead.  This is pretty low-level stuff and you
shouldn't have to use it or even know that it's here if you want to work with
SDL from Parrot.

On the other hand, if you want to use these functions directly, write your own
wrappers, or add wrappers that aren't already here, you should know how it
works.

=head2 The SDL Namespace

The C<SDL> namespace holds only a few functions right now, initializers for
various libraries.  These load the PASM code that actually creates the SDL NCI
bindings and initialize all of the SDL-specific data structures needed to
access structs passed to and returned from SDL calls.  There's no need to load
sound components if you don't have sound installed, for example.

Each struct layout has its own function that creates and stores the appropriate
data structure.  The order of calling really matters here, as some structs
contain other structs.

When you load this file with C<load_bytecode>, it initializes the C<SDL_video>
subsystem.  You'll have to use the appropriate IMC modules or initialize the
other subsystems manually.

The subsystem initializers include:

=over 4

=cut

.namespace [ 'SDL' ]

.include 'datatypes.pasm'

.macro store_nci_func( func_name, signature )
    c_func_name = prefix . .func_name
    dlfunc c_function, libsdl, c_func_name, .signature
    set_hll_global ['SDL::NCI'], .func_name, c_function
.endm

.sub _sdl_init :load
    _init_video()

    .local pmc layouts
    layouts = new 'OrderedHash'
    set_hll_global ['SDL::NCI'], 'layouts', layouts

    # this order matters; trust me!
    _set_Event_layout(        layouts )
    _set_Rect_layout(         layouts )
    _set_Rect_Array_layout(   layouts )
    _set_Color_layout(        layouts )
    _set_Palette_layout(      layouts )
    _set_PixelFormat_layout(  layouts )
    _set_Pixels_layout(       layouts )
    _set_Surface_layout(      layouts )

.end

=item _init_video()

Initialize the video subsystem.  You shouldn't ever need to call this directly.
In fact, don't count on it sticking around.  It may not.  Then again, it might.

=cut

.sub _init_video
    .local pmc libsdl
    .local pmc sdl_function

    loadlib libsdl, 'libSDL'
    if libsdl goto OK

    # second try
    loadlib libsdl, 'libSDL-1.2'
    if libsdl goto OK_HINT1

    # third try
    loadlib libsdl, 'libSDL-1.2.so.0'
    if libsdl goto OK_HINT2

    # cygwin
    loadlib libsdl, 'cygSDL-1-2-0'
    if libsdl goto OK

    # failed to load libSDL
    $P0 = new 'Exception'
    $P0 = "libSDL not found!"
    throw $P0
    branch OK
  OK_HINT1:
    printerr "Hint: create a link from libSDL-1.2.so to libSDL.so to disable the error messages.\n"
    branch OK
  OK_HINT2:
    printerr "Hint: create a link from libSDL-1.2.so.0 to libSDL_image.so to disable the error messages.\n"
  OK:
    .local string namespace
    namespace = 'SDL::NCI'

    .local string prefix
    prefix    = 'SDL_'

    .local string c_func_name
    .local pmc    c_function

    .store_nci_func( 'Init', 'ii' )

#    dlfunc sdl_function, libsdl, 'SDL_Init', 'ii'
#    set_hll_global ['SDL::NCI'], 'Init', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_SetVideoMode', 'piiil'
    set_hll_global ['SDL::NCI'], 'SetVideoMode', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_Quit', 'v'
    set_hll_global ['SDL::NCI'], 'Quit', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_FillRect', 'ippi'
    set_hll_global ['SDL::NCI'], 'FillRect', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_UpdateRect', 'vpiiii'
    set_hll_global ['SDL::NCI'], 'UpdateRect', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_UpdateRects', 'vpip'
    set_hll_global ['SDL::NCI'], 'UpdateRects', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_Flip', 'ip'
    set_hll_global ['SDL::NCI'], 'Flip', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_FreeSurface', 'vp'
    set_hll_global ['SDL::NCI'], 'FreeSurface', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_LoadBMP_RW', 'ppi'
    set_hll_global ['SDL::NCI'], 'LoadBMP_RW', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_DisplayFormat', 'pp'
    set_hll_global ['SDL::NCI'], 'DisplayFormat', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_UpperBlit', 'ipppp'
    set_hll_global ['SDL::NCI'], 'BlitSurface', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_WaitEvent', 'ip'
    set_hll_global ['SDL::NCI'], 'WaitEvent', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_PollEvent', 'ip'
    set_hll_global ['SDL::NCI'], 'PollEvent', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_GetKeyName', 'ti'
    set_hll_global ['SDL::NCI'], 'GetKeyName', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_GetError', 'tv'
    set_hll_global ['SDL::NCI'], 'GetError', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_SetColorKey', 'ipii'
    set_hll_global ['SDL::NCI'], 'SetColorKey', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_LockSurface', 'ip'
    set_hll_global ['SDL::NCI'], 'LockSurface', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_UnlockSurface', 'vp'
    set_hll_global ['SDL::NCI'], 'UnlockSurface', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_CreateRGBSurface', 'piiiiiiii'
    set_hll_global ['SDL::NCI'], 'CreateRGBSurface', sdl_function
    dlfunc sdl_function, libsdl, 'SDL_EventState', 'iii'
    set_hll_global ['SDL::NCI'], 'EventState', sdl_function
	dlfunc sdl_function, libsdl, 'SDL_GetTicks', 'iv'
	set_hll_global ['SDL::NCI'], 'GetTicks', sdl_function
	dlfunc sdl_function, libsdl, 'SDL_Delay', 'vi'
	set_hll_global ['SDL::NCI'], 'Delay', sdl_function
.end

=item _init_image()

Initialize the C<SDL_image> subsystem.  If you don't have the appropriate
library installed, this won't work very well.  You'll probably want to use the
SDL::Image library anyway, which calls this for you.

=cut

.sub _init_image
    .local pmc image_lib
    .local pmc nci_sub

    loadlib image_lib, 'libSDL_image'
    if image_lib goto OK

    loadlib image_lib, 'libSDL_image-1.2'
    if image_lib goto OK_HINT1

    loadlib image_lib, 'libSDL_image-1.2.so.0'
    if image_lib goto OK_HINT2

    loadlib image_lib, 'cygSDL_image-1-2-0'
    if image_lib goto OK

    # failed to load libSDL
    $P0 = new 'Exception'
    $P0 = "libSDL_image not found!"
    throw $P0
    branch OK
  OK_HINT1:
    printerr "Hint: create a link from libSDL_image-1.2.so to libSDL_image.so to disable the error messages.\n"
    branch OK
  OK_HINT2:
    printerr "Hint: create a link from libSDL_image-1.2.so.0 to libSDL_image.so to disable the error messages.\n"
  OK:
    dlfunc nci_sub, image_lib, 'IMG_Load', 'pt'
    set_hll_global ['SDL::NCI'], 'IMG_Load', nci_sub
.end

=item _init_ttf()

Initialize the C<SDL_ttf> subsystem.  If you don't have the appropriate
library installed, this won't work very well.  You'll probably want to use the
SDL::Font library anyway, which calls this for you.

=back

=cut

.sub _init_ttf
    .local pmc ttf_lib
    loadlib ttf_lib, 'libSDL_ttf'
    if ttf_lib goto initialize
    loadlib ttf_lib, 'cygSDL_ttf-2-0-0'
# RNH this is not trapping a non-existent libSDL_ttf library
    unless ttf_lib goto error

  initialize:
    .local pmc nci_sub
    dlfunc nci_sub, ttf_lib, 'TTF_Init', 'iv'
    unless nci_sub goto error

    set_hll_global ['SDL::NCI::TTF'], 'Init', nci_sub

    # TTF_init() returns 0 if successful, -1 on error
    .local int initialized
    initialized = nci_sub()
    unless initialized goto success

    # XXX: wow, this is unspectacular error handling!
  error:
    .local pmc e
    e    = new 'Exception'
    e[0] = "SDL_ttf not initialized\n"
    throw e

  success:
    dlfunc nci_sub, ttf_lib, 'TTF_OpenFont', 'pti'
    set_hll_global ['SDL::NCI::TTF'], 'OpenFont', nci_sub
#RNH changes: all text routines expect an integer, not a pmc, for color parameter
    dlfunc nci_sub, ttf_lib, 'TTF_RenderText_Solid', 'ppti'
    set_hll_global ['SDL::NCI::TTF'], 'RenderText_Solid', nci_sub
    dlfunc nci_sub, ttf_lib, 'TTF_RenderUTF8_Solid', 'ppti'
    set_hll_global ['SDL::NCI::TTF'], 'RenderUTF8_Solid', nci_sub

    # this one could be wrong
    dlfunc nci_sub, ttf_lib, 'TTF_RenderUNICODE_Solid', 'ppti'
    set_hll_global ['SDL::NCI::TTF'], 'RenderUNICODE_Solid', nci_sub
# RNH Additions. Add UTF8_Shaded and FontLine skip
    dlfunc nci_sub, ttf_lib, 'TTF_RenderUTF8_Shaded', 'pptii'
    set_hll_global ['SDL::NCI::TTF'], 'RenderUTF8_Shaded', nci_sub
    dlfunc nci_sub, ttf_lib, 'TTF_FontLineSkip', 'ip'
    set_hll_global ['SDL::NCI::TTF'], 'FontLineSkip', nci_sub
#end additions

    dlfunc nci_sub, ttf_lib, 'TTF_SizeText', 'ipt33'
    set_hll_global ['SDL::NCI::TTF'], 'SizeText', nci_sub
    dlfunc nci_sub, ttf_lib, 'TTF_SizeUTF8', 'ipt33'
    set_hll_global ['SDL::NCI::TTF'], 'SizeUTF8', nci_sub
    dlfunc nci_sub, ttf_lib, 'TTF_SizeUNICODE', 'ipt33'
    set_hll_global ['SDL::NCI::TTF'], 'SizeUNICODE', nci_sub

    dlfunc nci_sub, ttf_lib, 'TTF_CloseFont', 'vp'
    set_hll_global ['SDL::NCI::TTF'], 'CloseFont', nci_sub
    dlfunc nci_sub, ttf_lib, 'TTF_Quit', 'vv'
    set_hll_global ['SDL::NCI::TTF'], 'Quit', nci_sub
    dlfunc nci_sub, ttf_lib, 'TTF_WasInit', 'iv'
    set_hll_global ['SDL::NCI::TTF'], 'WasInit', nci_sub
.end

.sub _set_Event_layout
    .param pmc layouts

    .local pmc layout
    layout = new 'OrderedHash'

    # this is the only element in common in the SDL_Event union
    set  layout[ 'type' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'pad0' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'pad1' ], .DATATYPE_UINT16
    push layout, 0
    push layout, 0
    set  layout[ 'pad2' ], .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'pad3' ], .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'pad4' ], .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'pad5' ], .DATATYPE_UINT32
    push layout, 0
    push layout, 0

    set  layouts[ 'Event::Generic' ], layout

    # SDL_KeyboardEvent is the largest struct in the SDL_Event union
    layout = new 'OrderedHash'
    set  layout[ 'type' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'which' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'state' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'padding' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'scancode' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'padding_a' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'padding_b' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'padding_c' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'sym' ], .DATATYPE_INT
    push layout, 0
    push layout, 0
    set  layout[ 'mod' ], .DATATYPE_INT
    push layout, 0
    push layout, 0
    set  layout[ 'unicode' ], .DATATYPE_UINT16
    push layout, 0
    push layout, 0

    set  layouts[ 'Event::Keyboard' ], layout

    # SDL_MouseMotionEvent
    layout = new 'OrderedHash'
    set  layout[ 'type' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'pad0' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'state' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'x' ], .DATATYPE_UINT16
    push layout, 0
    push layout, 0
    set  layout[ 'y' ], .DATATYPE_UINT16
    push layout, 0
    push layout, 0
    set  layout[ 'xrel' ], .DATATYPE_INT16
    push layout, 0
    push layout, 0
    set  layout[ 'yrel' ], .DATATYPE_INT16
    push layout, 0
    push layout, 0

    set  layouts[ 'Event::MouseMotion' ], layout

    # SDL_MouseButtonEvent
    layout = new 'OrderedHash'
    set  layout[ 'type' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'button' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'state' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'x' ], .DATATYPE_UINT16
    push layout, 0
    push layout, 0
    set  layout[ 'y' ], .DATATYPE_UINT16
    push layout, 0
    push layout, 0

    set  layouts[ 'Event::MouseButton' ], layout
.end

.sub _set_Rect_layout
    .param pmc layouts
    .local pmc layout

    layout = new 'OrderedHash'
    set  layout[ 'x' ],      .DATATYPE_INT16
    push layout, 0
    push layout, 0
    set  layout[ 'y' ],      .DATATYPE_INT16
    push layout, 0
    push layout, 0
    set  layout[ 'width' ],  .DATATYPE_UINT16
    push layout, 0
    push layout, 0
    set  layout[ 'height' ], .DATATYPE_UINT16
    push layout, 0
    push layout, 0

    set  layouts[ 'Rect' ], layout
.end

.sub _set_Rect_Array_layout
    .param pmc layouts

    .local pmc fetch_struct
    fetch_struct = get_hll_global ['SDL::NCI'], 'fetch_struct'

    .local pmc rect
    rect   = fetch_struct( 'Rect', 0 )

    .local pmc layout
    layout = new 'OrderedHash'

    set  layout[ 'RectArray' ], .DATATYPE_STRUCT

    set     $P1, layout[ -1 ]
    setprop $P1, '_struct', rect

    # this is wrong; you need to reset it
    push layout, 0
    push layout, 0

    set  layouts[ 'Rect_Array' ], layout
.end

.sub _set_Surface_layout
    .param pmc layouts

    .local pmc fetch_struct
    fetch_struct = get_hll_global ['SDL::NCI'], 'fetch_struct'

    # SDL_PixelFormat struct pointer
    .local pmc pixelformat
    pixelformat = fetch_struct( 'PixelFormat', 0 )

    # SDL_Rect struct
    .local pmc rect
    rect        = fetch_struct( 'Rect', 0 )

    # SDL_Pixels struct (workaround?)
    .local pmc pixels
    rect        = fetch_struct( 'Pixels', 0 )

    .local pmc layout
    layout = new 'OrderedHash'
    set  layout[ 'flags' ], .DATATYPE_UINT32
    push layout, 0
    push layout, 0

    set  layout[ 'format' ], .DATATYPE_STRUCT_PTR

    # SDL_PixelFormat struct pointer
    .local pmc format_pointer
    set        format_pointer, layout[ -1 ]
    setprop    format_pointer, '_struct', pixelformat

    push layout, 0
    push layout, 0

    set  layout[ 'w' ],      .DATATYPE_INT
    push layout, 0
    push layout, 0
    set  layout[ 'h' ],      .DATATYPE_INT
    push layout, 0
    push layout, 0
    set  layout[ 'pitch' ],  .DATATYPE_UINT16
    push layout, 0
    push layout, 0

    .local pmc pixels_layout
    .local pmc pixels_array
    pixels_layout = new 'OrderedHash'

    set  pixels_layout[ 'array' ], .DATATYPE_INT
    push pixels_layout, 0
    push pixels_layout, 0
    pixels_array  = new 'UnManagedStruct', pixels_layout

    set  layout[ 'pixels' ], .DATATYPE_STRUCT_PTR
    set        format_pointer, layout[ -1 ]
    setprop    format_pointer, '_struct', pixels_array

    push layout, 0
    push layout, 0
    set  layout[ 'offset' ], .DATATYPE_INT
    push layout, 0
    push layout, 0

    # private_hwdata struct pointer
    set  layout[ 'hwdata' ], .DATATYPE_PTR

    push layout, 0
    push layout, 0

    set layout[ 'clip_rect' ], .DATATYPE_STRUCT

    .local pmc rect_pointer
    set        rect_pointer, layout[ -1 ]
    setprop    rect_pointer, '_struct', rect

    push layout, 0
    push layout, 0

    set  layout[ 'unused1' ], .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'locked' ], .DATATYPE_UINT32
    push layout, 0
    push layout, 0

    # SDL_BlitMap struct pointer
    set  layout[ 'map' ], .DATATYPE_PTR
    push layout, 0
    push layout, 0

    set  layout[ 'format_version' ], .DATATYPE_UINT
    push layout, 0
    push layout, 0
    set  layout[ 'refcount' ], .DATATYPE_INT
    push layout, 0
    push layout, 0

    set  layouts[ 'Surface' ], layout
.end

.sub _set_PixelFormat_layout
    .param pmc layouts

    .local pmc fetch_struct
    fetch_struct = get_hll_global ['SDL::NCI'], 'fetch_struct'

    .local pmc palette
    palette = fetch_struct( 'Palette', 0 )

    .local pmc layout
    layout = new 'OrderedHash'
    set  layout[ 'palette' ], .DATATYPE_STRUCT_PTR

    .local pmc palette_pointer
    set        palette_pointer, layout[ -1 ]
    setprop    palette_pointer, '_struct', palette

    push layout, 0
    push layout, 0

    set  layout[ 'BitsPerPixel' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'BytesPerPixel' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Rloss' ],         .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Gloss' ],         .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Bloss' ],         .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Aloss' ],         .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Rshift' ],        .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Gshift' ],        .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Bshift' ],        .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Ashift' ],        .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'Rmask' ],         .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'Gmask' ],         .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'Bmask' ],         .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'Amask' ],         .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'colorkey' ],      .DATATYPE_UINT32
    push layout, 0
    push layout, 0
    set  layout[ 'alpha' ],         .DATATYPE_UINT8
    push layout, 0
    push layout, 0

    set  layouts[ 'PixelFormat' ], layout
.end

.sub _set_Palette_layout
    .param pmc layouts

    .local pmc fetch_struct
    fetch_struct = get_hll_global ['SDL::NCI'], 'fetch_struct'

    .local pmc color
    color  = fetch_struct( 'Color', 0 )

    .local pmc layout
    layout = new 'OrderedHash'

    set  layout[ 'ncolors' ], .DATATYPE_INT
    push layout, 0
    push layout, 0
    set  layout[ 'colors' ],  .DATATYPE_STRUCT_PTR

    .local pmc color_pointer
    set        color_pointer, layout[ -1 ]
    setprop    color_pointer, '_struct', color

    push layout, 0
    push layout, 0

    set  layouts[ 'Palette' ], layout
.end

.sub _set_Color_layout
    .param pmc layouts

    .local pmc layout
    layout = new 'OrderedHash'

    set  layout[ 'r'      ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'g'      ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'b'      ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0
    set  layout[ 'unused' ], .DATATYPE_UINT8
    push layout, 0
    push layout, 0

    layouts[ 'Color' ] = layout
.end

.sub _set_Pixels_layout
    .param pmc layouts

    .local pmc layout
    layout = new 'OrderedHash'
    push layout, .DATATYPE_UINT16
    push layout, 2
    push layout, 0

    set  layouts[ 'Pixels' ], layout
.end

=head2 The SDL::NCI Namespace

Besides all of the actual NCI subs, there's one additional subroutine in the
SDL::NCI namespace.

C<fetch_layout()> takes one argument, a string containing the name of the SDL_*
data structure layout PMC to return.  You can then C<assign> the layout to an
C<UnManagedStruct> or C<ManagedStruct> PMC to assign to and read from various
struct members.

Note that the name of the layout has the leading C<SDL_> prefix removed; to
fetch the layout for an C<SDL_Rect> struct, ask for C<Rect>.

This currently doesn't do much if you request an unknown layout.  Suggestions
welcome.

In addition to the various SDL data structures, this makes the following other layouts available:

=over

=item * Rect_Array

An array of SDL_Rect structs.  Use this for such things as passing multiple
rects to a surface update function, for example.  Note that you'll have to
update the element at index 1 with the proper count of the number of rects in
the array.

If this confuses you, see C<SDL::Surface::update_rects()> and imagine how I<I>
felt when I wrote it!

=back

=cut

.namespace [ 'SDL::NCI' ]

.sub fetch_struct
    .param string struct_name
    .param int    managed

    .local pmc initializer
    .local pmc struct

#    .local pmc fetch_layout
#    fetch_layout = get_hll_global ['SDL::NCI'], 'fetch_layout'
    initializer  = fetch_layout( struct_name )

    if managed == 1 goto build_managed
    struct       = new 'UnManagedStruct', initializer
    goto built_struct

  build_managed:
    struct       = new 'ManagedStruct',   initializer

  built_struct:
    .return( struct )
.end

.sub fetch_layout
    .param string layout_name

    .local pmc layouts
    .local pmc layout

    layouts = get_hll_global ['SDL::NCI'], 'layouts'

    exists $I0, layouts[ layout_name ]
    if $I0 goto found
    layout = new 'OrderedHash'

    print "SDL::fetch_layout warning: layout '"
    print layout_name
    print "' not found!\n"
    goto found_done

  found:
    layout = layouts[ layout_name ]

  found_done:
    .return( layout )
.end

=head1 AUTHOR

Written and maintained by chromatic, E<lt>chromatic at wgz dot orgE<gt>.
Please send patches, feedback, and suggestions to the Perl 6 Internals mailing
list.

=head1 COPYRIGHT

Copyright (C) 2004-2008, Parrot Foundation.

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
