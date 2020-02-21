use v6.c;

use Method::Also;

use GTK::Clutter::Raw::Types;
use GTK::Clutter::Raw::Actor;

use GTK::Bin;
use GTK::Widget;

use Clutter::Actor;

class GTK::Clutter::Actor is Clutter::Actor {
  has GtkClutterActor $!ca;
  has $!contents;

  method bless(*%attrinit) {
    my $o = self.CREATE.BUILDALL(Empty, %attrinit);
    $o.setType($o.^name);
    $o;
  }

  submethod BUILD (:$clutter-actor, :$object) {
    # This will NOT accept an Ancestry!
    self.setActor( cast(ClutterActor, $!ca = $clutter-actor) );
    $!contents = $object;
  }

  multi method new (GtkClutterActor $clutter-actor) {
    $clutter-actor ?? self.bless(:$clutter-actor) !! Nil;
  }
  multi method new {
    my $clutter-actor = gtk_clutter_actor_new();

    $clutter-actor ?? self.bless(:$clutter-actor) !! Nil;
  }

  proto method new_with_contents (|)
    is also<new-with-contents>
  { * }

  multi method new_with_contents (GTK::Widget $object) {
    my $clutter-actor = gtk_clutter_actor_new_with_contents($object.Widget);

    $clutter-actor ?? self.bless(:$clutter-actor, :$object) !! Nil;
  }
  multi method new_with_contents (GtkWidget() $contents) {
    my $clutter-actor = gtk_clutter_actor_new_with_contents($contents);

    $clutter-actor ?? self.bless(:$clutter-actor) !! Nil;
  }

  method get_contents(:$raw = False, :$widget = False) is also<get-contents> {
    return $raw ?? $!contents.GtkWidget !! $!contents if $!contents;

    my $c = gtk_clutter_actor_get_contents($!ca);

    GTK::Widget.ReturnWidget($c, $raw, $widget);
  }

  method get_type is also<get-type> {
    state ($n, $t);

    unstable_get_type( self.^name, &gtk_clutter_actor_get_type, $n, $t );
  }

  # Return value MUST be GtkContainer or GTK::Container.
  method get_widget(:$raw = False, :container(:$widget) = False)
    is also<get-widget>
  {
    my $w = gtk_clutter_actor_get_widget($!ca);

    $w = GTK::Widget.ReturnWidget(cast(GtkWidget, $w), $raw, $widget);
    $w = GTK::Container.new($w.GtkWidget) if $w.WHAT ~~ GTK::Widget;
    $w;
  }

  # XXX - NOTE: When using GTK::Container methods to handle contents, the
  #       $!contents attribute will hang on to the widget specified at
  #       construction time. This will need overriding methods to correct!

}
