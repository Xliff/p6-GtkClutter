use v6.c;

use GTK::Compat::Types;
use GTK::Raw::Types;
use GTK::Clutter::Raw::Types;

use GTK::Clutter::Raw::Embed;

use GTK::Raw::Utils;

use GTK::Container;

use Clutter::Stage;

our subset EmbedAncestry of Mu is export
  where GtkClutterEmbed | ContainerAncestry;

class GTK::Clutter::Embed is GTK::Container {
  has GtkClutterEmbed $!gc;
  
  submethod BUILD (:$embed) {
    given $embed {
      when EmbedAncestry {
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
    self.bless( embed => gtk_clutter_embed_new() );
  }

  method use_layout_size is rw {
    Proxy.new(
      FETCH => sub ($) {
        so gtk_clutter_embed_get_use_layout_size($!gc);
      },
      STORE => sub ($, Int() $use_layout_size is copy) {
        my gboolean $u = resolve-bool($use_layout_size);
        gtk_clutter_embed_set_use_layout_size($!gc, $use_layout_size);
      }
    );
  }

  method get_stage {
    Clutter::Stage.new( gtk_clutter_embed_get_stage($!gc) )
  }

  method get_type {
    state ($n, $t);
    unstable_get_type( self.^name, &gtk_clutter_embed_get_type, $n, $t );
  }
  
}
