use v6.c;

use Method::Also;

use NativeCall;

use GTK::Clutter::Raw::Types

use Clutter::Stage;
use GTK::Window;

class GTK::Clutter::Window is GTK::Window {
  has GtkClutterWindow $!gcw;

  submethod BUILD (:$clutter-window) {
    self.setWindow( cast(GtkWindow, $!gcw = $clutter-window) )
  }

  method GTK::Clutter::Raw::Definitions::GtkClutterWindow
    is also<GtkClutterWindow>
  { $!gcw }

  multi method new (GtkClutterWindow $clutter-window) {
    $clutter-window ?? self.bless(:$clutter-window) !! Nil;
  }
  multi method new {
    my $clutter-window = gtk_clutter_window_new();

    $clutter-window ?? self.bless(:$clutter-window) !! Nil;
  }

  method get_stage (:$raw) is also<get-stage> {
    my $s = gtk_clutter_window_get_stage($!gcw);

    $s ??
      ( $raw ?? $s !! Clutter::Stage.new($s) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &gtk_clutter_window_get_type, $n, $t );
  }

}

sub gtk_clutter_window_get_stage (GtkClutterWindow $window)
  returns ClutterActor
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_window_get_type ()
  returns GType
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_window_new ()
  returns GtkClutterWindow
  is native(gtk-clutter)
  is export
{ * }
