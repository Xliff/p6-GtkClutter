use v6.c;

unit package GtkClutter::Raw::Exports;

our @gtk-clutter-exports is export;

BEGIN {
  @gtk-clutter-exports = <
    GTK::Clutter::Raw::Definitions
  >;
}
