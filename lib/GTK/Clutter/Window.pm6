use v6.c;

use Method::Also;

use NativeCall;

use GTK::Compat::Types;
use Clutter::Raw::Types;
use GTK::Raw::Types;
use GTK::Clutter::Raw::Types;

use Clutter::Stage;

use GTK::Window;

class GTK::Clutter::Window is GTK::Window {
  has GtkClutterWindow $!gcw;

  submethod BUILD (:$clutter-window) {
    self.setWindow( cast(GtkWindow, $!gcw = $clutter-window) )
  }

  multi method new (GtkClutterWindow $clutter-window) {
    self.bless(:$clutter-window)
  }
  multi method new {
    self.bless( clutter-window => gtk_clutter_window_new() );
  }

  method get_stage (:$raw) is also<get-stage> {
    my $s = gtk_clutter_window_get_stage($!gcw);
    $raw ?? $s !! Clutter::Stage.new($s);
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
