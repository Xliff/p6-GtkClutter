use v6.c;

use GTK::Compat::Types;
use GTK::Raw::Types;
use Clutter::Raw::Types;
use GTK::Clutter::Raw::Types;

use GLib::Timeout;

use GTK::Application;
use GTK::Box;
use GTK::Button;
use GTK::CheckButton;
use GTK::Entry;
use GTK::Label;

use Clutter::Actor;
use Clutter::AlignConstraint;
use Clutter::Stage;
use Clutter::Timeline;

use GTK::Clutter::Actor;
use GTK::Clutter::Embed;
use GTK::Clutter::Main;

constant MAX-NWIDGETS = 4;
constant WINWIDTH     = 400;
constant WINHEIGHT    = 400;
constant RADIUS       = 80;

my %globals;

sub on-frame($t, $ms, $ud) {
  CATCH { default { .message.say } }

  my $r = $t.get-progress * 360;
  return unless %globals<do-rotate>;

  %globals<group>.set-rotation-angle(CLUTTER_Z_AXIS, $r);
  for %globals<widgets>.Array {
    .opacity        = 50 * sin(2 * π * $r / 360) + 205;

    .set-rotation-angle(CLUTTER_Z_AXIS, -2 * $r);
  }
}

sub on-clicked ($b, $v) {
  say "button clicked";
  my $l = GTK::Label.new('A new label');
  $l.show;
  $v.pack-start($l);
}

sub create-gtk-actor {
  my $gtk-actor = GTK::Clutter::Actor.new;
  my $bin       = $gtk-actor.get-widget;
  my $vbox      = GTK::Box.new-vbox(6);
  my $button1   = GTK::Button.new-with-label('A Button');
  my $button2   = GTK::CheckButton.new-with-label('Another Button');
  my $entry     = GTK::Entry.new;

  $bin.add($vbox);
  $button1.clicked.tap({ on-clicked($button1, $vbox) });
  $vbox.pack-start($_) for $button1, $button2, $entry;
  $bin.show-all;

  $gtk-actor;
}

sub add-clutter-actor($a, $c, $i) {
  $c.add-child($a);

  my ($w, $h) = ($a.width, $a.height);
  my $x = WINWIDTH / 2 + RADIUS * cos(2 * $i * π / MAX-NWIDGETS) - $w / 2;
  my $y = WINHEIGHT / 2 + RADIUS * sin(2 * $i * π / MAX-NWIDGETS) - $h / 2;

  ($a.x, $a.y) = ($x, $y);
  $a.set-pivot-point(0.5, 0.5);
}

# Used by GLib::Timeout and NOT a signal handler.
sub add-or-remove-event ($) {
  CATCH { default { .message.say } }

  if %globals<widgets>.elems == MAX-NWIDGETS {
    %globals<group>.remove-child(%globals<widgets>.pop);
  } else {
    %globals<widgets>.push: create-gtk-actor;
    add-clutter-actor(%globals<widgets>[* - 1], %globals<group>, MAX-NWIDGETS-1);
  }

  G_SOURCE_CONTINUE;
}

sub MAIN (
  :$do-rotate = True     #= Sets whether the rotation is performed. Default = True.
) {
  die "Unable to initialize GtkClutter"
    unless GTK::Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  %globals<do-rotate> = $do-rotate;

  my $stage-color = Clutter::Color.new(0x61, 0x64, 0x8c, 0xff);
  my $window      = GTK::Window.new;
  my $vbox        = GTK::Box.new-vbox(6);
  my $clutter     = GTK::Clutter::Embed.new;
  my $stage       = $clutter.get-stage;
  my $button      = GTK::Button.new-with-mnemonic('_Quit');
  %globals<group> = Clutter::Actor.new;

  %globals<group>.set-pivot-point(0.5, 0.5);
  $button.clicked.tap({ GTK::Application.quit });
  $window.destroy-signal.tap({ GTK::Application.quit });
  $window.add($vbox);
  $clutter.set-size-request(WINWIDTH, WINHEIGHT);
  $vbox.pack-start($clutter, True, True);
  $vbox.pack-end($button);
  $stage.background-color = $stage-color;

  # cw: Staying as close to the original as possible...
  for ^MAX-NWIDGETS {
    %globals<widgets>.push: create-gtk-actor;
    add-clutter-actor(%globals<widgets>[$_], %globals<group>, $_);
  }

  # Add the group to the stage and center it.
  $stage.add-child(%globals<group>);
  %globals<group>.add-constraint(
    Clutter::AlignConstraint.new($stage, CLUTTER_ALIGN_BOTH, 0.5)
  );
  $window.show-all;

  # Create a timeline to manage animation.
  my $timeline = Clutter::Timeline.new(6000);
  $timeline.repeat-count = -1;

  $timeline.new-frame.tap(-> *@a { on-frame(|@a) });
  $timeline.start;

  GLib::Timeout.add-seconds(3, -> *@a { add-or-remove-event(|@a) }) ;

  GTK::Application.main;
}
