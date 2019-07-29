use v6.c;

use Method::Also;

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

  submethod BUILD (:$clutter-actor, :$object) {
    # This will NOT accept an Ancestry!
    self.setActor( cast(ClutterActor, $!ca = $clutter-actor) );
    $!contents = $object;
  }

  multi method new (GtkClutterActor $actor) {
    self.bless(:$actor);
  }
  multi method new {
    self.bless( clutter-actor => gtk_clutter_actor_new() );
  }

  proto method new_with_contents (|)
    is also<new-with-contents>
  { * }

  multi method new_with_contents (GTK::Widget $object) {
    self.bless(
      clutter-actor => gtk_clutter_actor_new_with_contents($object.Widget),
      :$object
    );
  }
  multi method new_with_contents (GtkWidget() $contents) {
    self.bless(
      clutter-actor => gtk_clutter_actor_new_with_contents($contents)
    );
  }

  method get_contents(:$raw) is also<get-contents> {
    my $c = gtk_clutter_actor_get_contents($!ca);
    $!contents ??
      ($raw ?? $!contents.Container !! $!contents)
      !!
      ( $raw ?? $c !! GTK::Container.new($c) )
  }

  method get_type is also<get-type> {
    state ($n, $t);
    unstable_get_type( self.^name, &gtk_clutter_actor_get_type, $n, $t );
  }

  method get_widget(:$raw) is also<get-widget> {
    my $w = gtk_clutter_actor_get_widget($!ca);
    $raw ?? $w !! GTK::Widget.CreateObject($w);
  }

  # XXX - NOTE: When using GTK::Container methods to handle contents, the
  #       $!contents attribute will hang on to the contents specified at
  #       construction time. This will need overriding methods to correct!

}
