use v6.c;

use GTK::Compat::Types;
use Clutter::Raw::Types;
use GTK::Raw::Types;
use GTK::Clutter::Raw::Types;

use GTK::Clutter::Raw::Actor;

use GTK::Roles::Data;

use GTK::Widget;

use Clutter::Actor;

class GTK::Clutter::Actor is Clutter::Actor {
  has GtkClutterActor $!ca;
  has $!contents;

  submethod BUILD (:$actor) {
    # This will NOT accept an Ancestry!
    self.setActor( cast(ClutterActor, $!ca = $actor) );
  }

  multi method new (GtkClutterActor $actor) {
    self.bless(:$actor);
  }
  multi method new {
    self.bless( actor => gtk_clutter_actor_new() );
  }

  multi method new_with_contents (GTK::Widget $contents) {
    $!contents = $contents;
    samewith($contents.Widget);
  }
  multi method new_with_contents (GtkWidget() $contents) {
    self.bless( actor => gtk_clutter_actor_new_with_contents($contents) );
  }

  method get_contents(:$raw) {
    my $c = gtk_clutter_actor_get_contents($!ca);
    $!contents ??
      ($raw ?? $!contents.Container !! $!contents)
      !!
      ( $raw ?? $c !! GTK::Container.new($c) )
  }

  method get_type {
    state ($n, $t);
    unstable_get_type( self.^name, &gtk_clutter_actor_get_type, $n, $t );
  }

  method get_widget(:$raw) {
    my $w = gtk_clutter_actor_get_widget($!ca);
    $raw ?? $w !! GTK::Widget.CreateObject($w);
  }

}
