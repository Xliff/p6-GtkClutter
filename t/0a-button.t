use v6.c;

use GTK::Clutter::Raw::Types;

use GTK::Application;
use GTK::Adjustment;
use GTK::Box;
use GTK::Button;
use GTK::Scale;

use Clutter::Actor;
use Clutter::AlignConstraint;

use GTK::Clutter::Actor;
use GTK::Clutter::Embed;
use GTK::Clutter::Main;

# I've wanted a way to do this since I saw the raw GTK version.
# This is mine.

sub MAIN {
  die 'Could not initialize GTK::Clutter'
    unless GTK::Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  my $window = GTK::Window.new;
  my $vbox   = GTK::Box.new-vbox;
  my $scale  = GTK::Scale.new-with-range(0, 90, 1, :horizontal);
  my $embed  = GTK::Clutter::Embed.new;
  my $stage  = $embed.get-stage;
  my $actor  = GTK::Clutter::Actor.new;
  my $bin    = $actor.get-widget;
  my $button = GTK::Button.new-with-label('A Button');

  $window.title = 'RotateButton';
  $window.destroy-signal.tap({ GTK::Application.quit; exit });
  $window.set-default-size(200, 200);
  $window.add($vbox);
  $vbox.add($_) for $scale, $embed;
  $actor.set-pivot-point(0, 0);
  $stage.add-child($actor);
  $actor.show-actor;
  $bin.add($button);
  .show-all for $bin, $window;;

  $actor.add-constraints(
    Clutter::AlignConstraint.new($stage, CLUTTER_X_AXIS, 0.5),
    Clutter::AlignConstraint.new($stage, CLUTTER_Y_AXIS, 0.3)
  );

  $button.clicked.tap({
    state $c = 0;
    say "Button clicked { ++$c } times!"
  });
  $scale.value-changed.tap({
    $actor.set-rotation-angle(CLUTTER_Z_AXIS, $scale.value)
  });

  GTK::Application.main;
}
