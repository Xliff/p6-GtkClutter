use v6.c;

use Method::Also;

use GTK::Clutter::Raw::Types;
use GTK::Clutter::Raw::Embed;

use GTK::Container;

use Clutter::Stage;

our subset GtkClutterEmbedAncestry of Mu is export
  where GtkClutterEmbed | ContainerAncestry;

class GTK::Clutter::Embed is GTK::Container {
  has GtkClutterEmbed $!gc;

  submethod BUILD (:$embed) {
    given $embed {

      when GtkClutterEmbedAncestry {
        my $to-parent;
        $!gc = do {
          when GtkClutterEmbed {
            $to-parent = cast(GtkContainer, $_);
            $_;
          }

          default {
            $to-parent = $_;
            cast(GtkClutterEmbed, $_);
          }
        }
        self.setContainer($to-parent);
      }

      when GTK::Clutter::Embed {
      }

      default {
      }
    }
  }

  method new {
    my $embed = gtk_clutter_embed_new();

    $embed ?? self.bless( :$embed  ) !! Nil;
  }

  method use_layout_size is rw is also<use-layout-size> {
    Proxy.new(
      FETCH => sub ($) {
        so gtk_clutter_embed_get_use_layout_size($!gc);
      },
      STORE => sub ($, Int() $use_layout_size is copy) {
        my gboolean $u = $use_layout_size.so.Int;

        gtk_clutter_embed_set_use_layout_size($!gc, $use_layout_size);
      }
    );
  }

  method get_stage (:$raw = False) is also<get-stage>  {
    my $s = gtk_clutter_embed_get_stage($!gc);

    $s ??
      ( $raw ?? $s !! Clutter::Stage.new($s) )
      !!
      Nil;
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &gtk_clutter_embed_get_type, $n, $t );
  }

}
