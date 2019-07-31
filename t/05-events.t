use v6.c;

use GTK::Compat::Types;
use GTK::Raw::Types;
use Clutter::Raw::Types;
use GTK::Clutter::Raw::Types;

use Clutter::Actor;
use Clutter::AlignConstraint;
use Clutter::Color;
use Clutter::Event;
use Clutter::Stage;
use Clutter::Text;

use GTK::Application;
use GTK::Box;
use GTK::Entry;
use GTK::Label;
use GTK::SizeGroup;
use GTK::SpinButton;
use GTK::Window;

use GTK::Clutter::Embed;
use GTK::Clutter::Main;
use GTK::Clutter::Texture;

my %globals;

constant DATA-PATH = '.';

sub on-stage-capture($s, $e, $ud, $r) {
  $r.r = 0;

  my $event = Clutter::Event.new($e);
  my $etype = $event.event-type;

  given $etype {
    when CLUTTER_BUTTON_PRESS | CLUTTER_BUTTON_RELEASE {
      my ($x, $y) = $event.get-coords;

      say "Button { $etype.Str.split('_')[* - 1].lc.tc
          } captured at ({ $x.fmt('%.2f') }, { $y.fmt('%.2f') }";
    }

    when CLUTTER_ENTER | CLUTTER_LEAVE {
      my $r = $event.related;

      # Remember that .p means 'Pointer'...
      if $r.defined &&
         +$event.source(:raw).p == +$s.ClutterStage.p
      {
        say sprintf "%s the stage and %s '%s'",
          $etype == CLUTTER_ENTER ?? 'Entering' !! 'Leaving',
          $etype == CLUTTER_ENTER ?? 'leaving' !! 'entering',
          $r.name // '<UNK>';
      }
    }

    when CLUTTER_KEY_PRESS {
      my $k = $event.key-unicode;
      say
        sprintf "The stage got a key press: '%s' (symbol: %d, unicode: 0x%x)",
          $k.chr, $event.key-symbol, $k;
    }
  }
}

sub MAIN {
  die 'Unable to initialize GtkClutter'
    unless GTK::Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  # Create the initial gtk window and widgets, just like normal
  with %globals<window> = GTK::Window.new {
    .title = 'GTK-Clutter Interaction Demo';
    .set-default-size(800, 600);
    ( .resizable, .border-width ) = (True, 12);
    .destroy-signal.tap({ GTK::Application.quit });
  }

  # Create our layout box
  my $hbox = GTK::Box.new-hbox(12);
  %globals<vbox> = GTK::Box.new-vbox(12);
  %globals<window>.add(%globals<vbox>);

  with %globals<gtk-entry> = GTK::Entry.new {
    .text = 'Enter some text';
    .changed.tap(-> *@a { %globals<clutter-entry>.text = @a[0].text });
    %globals<vbox>.pack-start($_);
  }
  %globals<vbox>.pack-start($hbox, True, True);

  my $embed = GTK::Clutter::Embed.new;
  with $embed {
    .enter-notify-event.tap(-> *@a {
      say "Entering widget '{ $embed.name }'";
      @a[* - 1].r = 0;
    });
    .leave-notify-event.tap(-> *@a {
      say "Leaving widget '{ $embed.name }'";
      @a[* - 1].r = 0;
    });
    .grab-focus;
  }

  .captured-event.tap(-> *@a { on-stage-capture(|@a) })
    with %globals<stage> = $embed.get-stage;

  $hbox.pack-start($embed, True, True);

  my $path = DATA-PATH.IO;
  my $filename = $path.add('redhand.png');
  unless $filename.e {
    $path .= add('t');
    $filename = $path.add('redhand.png');
  }
  die "Cannot find image file '{ $filename }'" unless $filename.IO.e;
  my $pixbuf = GTK::Compat::Pixbuf.new-from-file($filename);

  %globals<hand> = GTK::Clutter::Texture.new;
  %globals<hand>.set-from-pixbuf($pixbuf);
  %globals<stage>.add-child(%globals<hand>);
  %globals<hand>.set-pivot-point(0.5, 0.5);
  %globals<hand>.add-constraint(
    Clutter::AlignConstraint.new(%globals<stage>, CLUTTER_ALIGN_BOTH, 0.5)
  );
  ( %globals<hand>.reactive, %globals<hand>.name ) = (True, 'Red Hand');
  %globals<hand>.button-press-event.tap(-> *@a {
    say "Button press on hand ({ @a[0].getType })";
    @a[* - 1].r = 0;
  });
  %globals<hand>.show-actor;

  # Setup the Clutter entry
  my $black := $CLUTTER_COLOR_Black;
  %globals<clutter-entry> = Clutter::Text.new-with-color($black).setup(
    position => 0 xx 2,
    size     => (500, 20)
  );
  %globals<stage>.add-child(%globals<clutter-entry>);

  # Create our adjustment widgets
  my $size-group = GTK::SizeGroup.new(GTK_SIZE_GROUP_HORIZONTAL);
  my $hvbox = GTK::Box.new-vbox(6);
  $hbox.pack-start($hvbox);

  # cw: Create spin buttons.
  my @sb = (
    [ 'Rotate x-axis',  CLUTTER_X_AXIS ],
    [ 'Rotate y-axis',  CLUTTER_Y_AXIS ],
    [ 'Rotate z-axis',  CLUTTER_Z_AXIS ],
    [ 'Adjust opacity', -> $, $s { %globals<hand>.opacity = $s.value } ]
  );

  my $default-h = -> $a, $b {
    %globals<hand>.set-rotation-angle($a, $b.value)
  };
  for @sb -> $s {
    my $is-axis = $s[0].starts-with('Adjust').not;
    my $box     = GTK::Box.new-hbox(6);
    my $label   = GTK::Label.new( $s[0] );
    my $button  = GTK::SpinButton.new-with-range(0, $is-axis ?? 360 !! 255, 1);
    my $sub     = $is-axis ?? $default-h !! $s[1];

    $hvbox.pack-start($box);
    $size-group.add-widget($label);
    $box.pack-start($_ , True, True) for $label, $button;
    $button.value-changed.tap({ $sub( $s[1], $button ) });
    $button.value = 255 unless $is-axis;
  }

  %globals<window>.show-all;
  # Only show/show_all the stage after the parent. widget_show will call
  # show on the stage.
  %globals<stage>.show-actor;

  GTK::Application.main;
}
