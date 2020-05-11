use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GLib::Raw::Structs;
use Clutter::Raw::Definitions;
use GTK::Clutter::Raw::Definitions;

unit package GTK::Clutter::Raw::Embed;

sub gtk_clutter_embed_get_stage (GtkClutterEmbed $embed)
  returns ClutterStage
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_embed_get_type ()
  returns GType
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_embed_new ()
  returns GtkClutterEmbed
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_embed_get_use_layout_size (GtkClutterEmbed $embed)
  returns uint32
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_embed_set_use_layout_size (
  GtkClutterEmbed $embed,
  gboolean $use_layout_size
)
  is native(gtk-clutter)
  is export
{ * }
