use v6.c;

use NativeCall;

use GTK::Compat::Types;
use Clutter::Raw::Types;
use GTK::Raw::Types;
use GTK::Clutter::Raw::Types;

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
