use v6.c;

use NativeCall;

use GTK::Compat::Types;

use GTK::Roles::Pointers;

unit package GTK::Clutter::Raw::Types;

# Number of times a forced compile has been made.
constant forced = 0;

constant gtk-clutter is export = 'clutter-gtk-1.0',v0;

class GtkClutterActor is repr('CPointer') does GTK::Roles::Pointers is export { }
class GtkClutterEmbed is repr('CPointer') does GTK::Roles::Pointers is export { }
