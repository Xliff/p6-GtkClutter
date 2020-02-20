use v6.c;

use NativeCall;

use GTK::Clutter::Raw::Types;

unit package GTK::Clutter::Raw::Texture;

sub gtk_clutter_texture_error_quark ()
  returns GQuark
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_texture_get_type ()
  returns GType
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_texture_new ()
  returns GtkClutterTexture
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_texture_set_from_icon_name (
  GtkClutterTexture $texture,
  GtkWidget $widget,
  Str $icon_name,
  guint32 $icon_size, # GtkIconSize $icon_size,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_texture_set_from_pixbuf (
  GtkClutterTexture $texture,
  GdkPixbuf $pixbuf,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_texture_set_from_stock (
  GtkClutterTexture $texture,
  GtkWidget $widget,
  Str $stock_id,
  guint $icon_size, # GtkIconSize $icon_size,
  CArray[Pointer[GError]] $error
)
  returns uint32
  is native(gtk-clutter)
  is export
{ * }
