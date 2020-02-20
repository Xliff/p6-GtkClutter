use v6.c;

use Method::Also;

use NativeCall;

use GTK::Clutter::Raw::Types;

use Clutter::Stage;

use GTK::Window;

our subset GtkClutterWindowAncestry is export of Mu
  where GtkClutterWindow | WindowAncestry;

class GTK::Clutter::Window is GTK::Window {
  has GtkClutterWindow $!gcw;

  submethod BUILD (:$clutter-window) {
    given $clutter-window {
      when GtkClutterWindowAncestry {
        my $to-parent;
        $!gcw = do {
          when GtkClutterWindow {
            $to-parent = cast(GtkWindow, $_);
            $_;
          }

          default {
            $to-parent = $_;
            cast(GtkClutterWindow, $_);
          }
        }
        self.setWindow($to-parent)
      }

      when GTK::Clutter::Window {
      }

      default {
      }
    }
  }

  multi method new (GtkClutterWindowAncestry $clutter-window) {
    $clutter-window ?? self.bless(:$clutter-window) !! Nil;
  }
  multi method new {
    my $clutter-window = gtk_clutter_window_new();

    $clutter-window ?? self.bless(:$clutter-window) !! Nil;
  }

  method get_stage (:$raw = False) is also<get-stage> {
    my $s = gtk_clutter_window_get_stage($!gcw);

    $s ??
      ( $raw ?? $s !! Clutter::Stage.new($s) )
      !!
      ClutterStage
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
