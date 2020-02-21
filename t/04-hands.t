use v6.c;

use GTK::Clutter::Raw::Types;
use Clutter::Raw::Keysyms;


use GDK::Pixbuf;
use GTK::Application;
use GTK::Button;
use GTK::Box;
use GTK::Grid;
use GTK::Label;
use GTK::Stack;

use Clutter::Actor;
use Clutter::Clone;
use Clutter::Color;
use Clutter::Event;
use Clutter::Stage;

use GTK::Clutter::Embed;
use GTK::Clutter::Main;
use GTK::Clutter::Texture;

constant NUM-HANDS  = 4;
constant WIN-HEIGHT = 400;
constant WIN-WIDTH  = 400;
constant RADIUS     = 150;
constant DATA-PATH  = '.';

my (%oh, %globals);

sub on-input($s, $e, $ud, $r) {
  CATCH { default { .message.say } }

  $r.r = 1;
  my $event = Clutter::Event.new($e);
  my $event-type = $event.event-type;

  if $event-type == CLUTTER_BUTTON_PRESS {
    my ($x, $y) = $event.get-coords;
    my $a = $s.get-actor-at-pos(CLUTTER_PICK_ALL, $x, $y);

    # Consider using GTK::Compat::Roles::Data to make something like this possible.
    # (a != NULL && (CLUTTER_IS_TEXTURE (a) || CLUTTER_IS_CLONE (a)))
    $a.hide-actor if $a &&
                     $a.getType eq <Clutter::Clone GTK::Clutter::Texture>.any;

  } elsif $event-type == CLUTTER_KEY_PRESS {
    my $k = $event.key-symbol;
    say "*** key press event (key: { $k }) ***";
    given $k {
      when CLUTTER_KEY_q { GTK::Application.quit; exit     }
      when CLUTTER_KEY_r { .show for %oh<hand>.Array       }
    }
  }

}

sub on-frame ($t, $ms, $ud) {
  my $rotation = $t.get-progress * 360;

  %oh<group>.set-rotation-angle(CLUTTER_Z_AXIS, $rotation);
  for %oh<hand>.Array {
    .set-rotation-angle(CLUTTER_Z_AXIS, -6 * $rotation);
    .opacity = 255 - $rotation % 255
  }
}

sub MAIN {
  die 'Could not initialize GTK::Clutter'
    unless GTK::Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  my $path = DATA-PATH.IO;
  my $filename = $path.add('redhand.png');
  unless $filename.e {
    $path .= add('t');
    $filename = $path.add('redhand.png');
  }
  die "Cannot find image file '{ $filename }'" unless $filename.IO.e;

  my $pixbuf = GDK::Pixbuf.new-from-file($filename);
  die 'pixbuf load failed' unless $pixbuf;

  my $window  = GTK::Window.new;
  my $vbox    = GTK::Grid.new-vgrid;
  my $stack   = GTK::Stack.new;
  my $label1  = GTK::Label.new('This is a label in a stack.');
  my $label2  = GTK::Label.new('This is a label');
  my $clutter = GTK::Clutter::Embed.new;
  my $stage   = $clutter.get-stage;
  my $button1 = GTK::Button.new-with-label('This is a button...clicky');
  my $button2 = GTK::Button.new-with-mnemonic('_Fullscreen');
  my $button3 = GTK::Button.new-with-mnemonic('_Quit');

  $window.destroy-signal.tap({ GTK::Application.quit });
  $window.title = 'Clutter Embedding';
  $window.set-default-size(WIN-WIDTH, WIN-HEIGHT);
  $window.add($vbox);
  $vbox.hexpand = $vbox.vexpand = True;
  $stack.add-named($label1, 'label');
  $stack.add-named($clutter, 'clutter');
  #$clutter.realize;
  $stage.background-color = $CLUTTER_COLOR_LightSkyBlue;

  .hexpand = True for         $label2, $button1, $button2, $button3;
  $vbox.add($_)   for $stack, $label2, $button1, $button2, $button3;

  $button1.clicked.tap({
    $stack.visible-child-name =
      $stack.visible-child-name eq 'label' ?? 'clutter' !! 'label';
    %globals<fade> .= not;
  });

  $button2.clicked.tap({
    $window.fullscreen   if %globals<fullscreen>.not;
    $window.unfullscreen if %globals<fullscreen>;
    %globals<fullscreen> .= not;
  });

  $button3.clicked.tap({ GTK::Application.quit; exit });

  %oh<stage> = $stage;
  %oh<group> = Clutter::Actor.new.setup( pivot-point => 0.5 xx 2 );

  for ^NUM-HANDS {
    if $_ == 0 {
      %oh<hand>[$_] = GTK::Clutter::Texture.new;
      %oh<hand>[$_].set_from_pixbuf($pixbuf);
    } else {
      %oh<hand>[$_] = Clutter::Clone.new(%oh<hand>[0]);
    }

    my $first-hand := %oh<hand>[0];
    my $this-hand  := %oh<hand>[$_];
    my ($w, $h) = ($first-hand.width, $first-hand.height);
    my $x = WIN-WIDTH  / 2 + RADIUS * cos( π * $_ / (NUM-HANDS * 0.5) ) - $w / 2;
    my $y = WIN-HEIGHT / 2 + RADIUS * sin( π * $_ / (NUM-HANDS * 0.5) ) - $h / 2;
    $this-hand.set-position($x, $y);
    $this-hand.set-pivot-point(0.5, 0.5);
    %oh<group>.add-child($this-hand);
  }

  $stage.add-child(%oh<group>);
  $stage.button-press-event.tap(-> *@a { on-input(|@a) });
  $stage.key-release-event.tap( -> *@a { on-input(|@a) });
  $window.show-all;

  my $timeline = Clutter::Timeline.new(6000);
  $timeline.repeat-count = -1;
  $timeline.new-frame.tap(-> *@a { on-frame(|@a) });
  $timeline.start;

  GTK::Application.main;
}
