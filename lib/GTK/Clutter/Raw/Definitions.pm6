use v6.c;

use NativeCall;

use GLib::Raw::Definitions;

use GLib::Roles::Pointers;

unit package GTK::Clutter::Raw::Definitions;

# Number of times a forced compile has been made.
constant forced = 3;

constant gtk-clutter is export = 'clutter-gtk-1.0',v0;

class GtkClutterActor    is repr<CPointer> does GLib::Roles::Pointers is export { }
class GtkClutterEmbed    is repr<CPointer> does GLib::Roles::Pointers is export { }
class GtkClutterWindow   is repr<CPointer> does GLib::Roles::Pointers is export { }
class GtkClutterTexture  is repr<CPointer> does GLib::Roles::Pointers is export { }