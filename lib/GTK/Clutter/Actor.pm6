use v6.c;

use Method::Also;

use GTK::Clutter::Raw::Types;
use GTK::Clutter::Raw::Actor;

use GTK::Bin;
use GTK::Widget;

use Clutter::Actor;

our subset GtkClutterActorAncestry is export of Mu
  where GtkClutterActor | ClutterActorAncestry;

class GTK::Clutter::Actor is Clutter::Actor {
  has GtkClutterActor $!ca;
  has $!contents;

  method bless(*%attrinit) {
    my $o = self.CREATE.BUILDALL(Empty, %attrinit);
    $o.setType($o.^name);
    $o;
  }

  submethod BUILD (:$gtk-clutter-actor, :$object) {
    self.setGtkClutterActor($gtk-clutter-actor);
    $!contents = $object;
  }

  method setGtkClutterActor (GtkClutterActorAncestry $_) {
    my $to-parent;

    $!ca = do {
      when GtkClutterActor {
        $to-parent = cast(ClutterActor, $_);
        $_;
      }

      default {
        $to-parent = $_;
        cast(GtkClutterActor, $_);\
      }
    }

    self.setClutterActor($to-parent);
  }

  multi method new (GtkClutterActorAncestry $gtk-clutter-actor) {
    $gtk-clutter-actor ?? self.bless( :$gtk-clutter-actor ) !! Nil
  }
  multi method new {
    my $gtk-clutter-actor = gtk_clutter_actor_new();

    $gtk-clutter-actor ?? self.bless( :$gtk-clutter-actor ) !! Nil
  }

  proto method new_with_contents (|)
    is also<new-with-contents>
  { * }

  multi method new_with_contents (GTK::Widget $object) {
    samewith($object.Widget);
  }
  multi method new_with_contents (GtkWidget() $contents) {
    my $gtk-clutter-actor = gtk_clutter_actor_new_with_contents($contents);

    $gtk-clutter-actor ?? self.bless( :$gtk-clutter-actor ) !! Nil
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

    # Lowest we can drop down to is GTK::Container.
    my $t = GTK::Widget.getType($w);
    $raw ?? $w !!
            $t.defined && $t.trim.chars ??
              GTK::Widget.CreateObject($w) !! GTK::Container.new($w);
  }

  # XXX - NOTE: When using GTK::Container methods to handle contents, the
  #       $!contents attribute will hang on to the contents specified at
  #       construction time. This will need overriding methods to correct!

}
