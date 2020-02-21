use v6.c;

use GTK::Clutter::Raw::Types;

use Clutter::Actor;
use Clutter::AlignConstraint;

use GTK::Application;
use GTK::Box;
use GTK::Notebook;
use GTK::Window;

use GTK::Clutter::Embed;
use GTK::Clutter::Main;
use GTK::Clutter::Texture;

my (%globals, @clutter);

sub create-tex($stage, $icon) {
  my $tex = GTK::Clutter::Texture.new;
  my $is-info = $icon.ends-with('information');

  $tex.set-from-icon-name(
    @clutter[1],
    $icon,
    $is-info ?? GTK_ICON_SIZE_DIALOG !! GTK_ICON_SIZE_BUTTON
  );
  if $is-info {
    $tex.set-position(160 - $tex.width / 2, 120 - $tex.height / 2);
  } else {
    $tex.add-constraint(
      Clutter::AlignConstraint.new(
        $stage, CLUTTER_ALIGN_BOTH, 0.5
      )
    );
  }
  $stage.add-child($tex);
  $tex.show-actor;
}

sub MAIN {
  exit(1) unless GTK::Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  my @col = (
    Clutter::Color.new(0xdd, 0xff, 0xdd, 0xff),
    Clutter::Color.new(0xff, 0xff, 0xff, 0xff),
    Clutter::Color.new(   0,    0,    0, 0xff)
  );

  my $notebook = GTK::Notebook.new;
  %globals<vbox> = ( my $vbox = GTK::Box.new-vbox(6) );

  # cw: This isn't working... perhaps something overriding the options?
  #
  # my $window = GTK::Window.new(
  #   'Multiple GtkClutterEmbed',
  #   width => 600, height =>  400
  # );
  #
  # Workaround:
  my $window = GTK::Window.new;
  #
  $window.title = 'Multiple GtkClutterEmbed';
  $window.set-default-size(600, 400);

  $window.add($notebook);
  $window.destroy-signal.tap({
    GTK::Application.quit;
    # Should not be necessary, but is. Is there another source?
    exit;
  });
  @clutter = GTK::Clutter::Embed.new xx 3;
  $notebook.append-page(@clutter[0], 'One stage');
  $notebook.append-page($vbox, 'Two stages');
  $vbox.add($_) for @clutter[1, 2];

  my @stage = @clutter.map( *.get-stage );
  @stage[$_].background-color = @col[$_] for @col.keys;

  my $d = 1;
  .set-size-request(320, 240/$d++) for @clutter;

  # Replacement for GTK::Clutter::Texture?!
  create-tex(@stage[1], 'dialog-information');
  create-tex(@stage[2], 'user-info');

  $window.show-all;

  GTK::Application.main;
}
