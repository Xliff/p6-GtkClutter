use v6.c;

use NativeCall;

use GTK::Compat::Types;
use GTK::Raw::Types;
use Clutter::Raw::Types;
use GTK::Clutter::Raw::Types;

use GTK::Raw::Utils;

use GTK::Clutter::Raw::Texture;

use Clutter::Actor;

class GTK::Clutter::Texture is Clutter::Actor {
  has GtkClutterTexture $!gct;

  method bless(*%attrinit) {
    my $o = self.CREATE.BUILDALL(Empty, %attrinit);
    $o.setType($o.^name);
    $o;
  }

  submethod BUILD (:$texture) {
    given $texture {
      when GtkClutterTexture {
        self.setActor( cast(ClutterActor, $!gct = $_) )
      }
      when GTK::Clutter::Texture {
      }
      default {
      }
    }
  }

  multi method new (GtkClutterTexture $texture) {
    self.bless(:$texture);
  }
  multi method new {
    self.bless( texture => gtk_clutter_texture_new() );
  }

  method error_quark {
    gtk_clutter_texture_error_quark();
  }

  method get_type {
    state ($n, $t);
    unstable_get_type( self.^name, &gtk_clutter_texture_get_type, $n, $t );
  }

  method set_from_icon_name (
    GtkWidget() $widget,
    Str() $icon_name,
    Int() $icon_size,
    CArray[Pointer[GError]] $error
  ) {
    my $is = resolve-int($icon_size);
    clear_error;
    my $rc = gtk_clutter_texture_set_from_icon_name(
      $!gct, $widget, $icon_name, $icon_size, $error
    );
    set_error($error);
    $rc;
  }

  method set_from_pixbuf (
    GdkPixbuf() $pixbuf,
    CArray[Pointer[GError]] $error = gerror
  ) {
    clear_error;
    my $rc = gtk_clutter_texture_set_from_pixbuf($!gct, $pixbuf, $error);
    set_error($error);
    $rc;
  }

  method set_from_stock (
    GtkWidget() $widget,
    Str $stock_id,
    Int() $icon_size,
    CArray[Pointer[GError]] $error = gerror
  ) {
    my $is = resolve-int($icon_size);
    clear_error;
    my $rc = gtk_clutter_texture_set_from_stock(
      $!gct, $widget, $stock_id, $is, $error
    );
    set_error($error);
    $rc;
  }

}
