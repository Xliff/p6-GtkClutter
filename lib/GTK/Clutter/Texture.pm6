use v6.c;

use Method::Also;
use NativeCall;

use GTK::Clutter::Raw::Types;
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

  method GTK::Clutter::Raw::Types::GtkClutterTexture
    is also<ClutterTexture>
  { * }

  multi method new (GtkClutterTexture $texture) {
    $texture ?? self.bless(:$texture) !! Nil;
  }
  multi method new {
    my $texture = gtk_clutter_texture_new();

    $texture ?? self.bless(:$texture) !! Nil;
  }

  method error_quark is also<error-quark> {
    gtk_clutter_texture_error_quark();
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &gtk_clutter_texture_get_type, $n, $t );
  }

  method set_from_icon_name (
    GtkWidget() $widget,
    Str() $icon_name,
    Int() $icon_size,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-from-icon-name>
  {
    my $is = $icon_size;

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
  )
    is also<set-from-pixbuf>
  {
    clear_error;
    my $rc = gtk_clutter_texture_set_from_pixbuf($!gct, $pixbuf, $error);
    set_error($error);
    $rc;
  }

  method set_from_stock (
    GtkWidget() $widget,
    Str() $stock_id,
    Int() $icon_size,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<set-from-stock>
  {
    my GtkIconSize $is = $icon_size;

    clear_error;
    my $rc = gtk_clutter_texture_set_from_stock(
      $!gct, $widget, $stock_id, $is, $error
    );
    set_error($error);
    $rc;
  }

}
