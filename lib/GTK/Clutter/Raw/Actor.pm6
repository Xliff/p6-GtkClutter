use v6.c;

use NativeCall;

use GLib::Raw::Definitions;
use GTK::Raw::Definitions;
use GTK::Clutter::Raw::Definitions;

unit package GTK::Clutter::Raw::Actor;

sub gtk_clutter_actor_get_contents (GtkClutterActor $actor)
  returns GtkWidget
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_actor_get_type ()
  returns GType
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_actor_get_widget (GtkClutterActor $actor)
  returns GtkContainer
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_actor_new ()
  returns GtkClutterActor
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_actor_new_with_contents (GtkWidget $contents)
  returns GtkClutterActor
  is native(gtk-clutter)
  is export
{ * }
