use v6.c;

use GTK::Compat::Types;
use Clutter::Compat::Types;
use Clutter::Raw::Types;
use GTK::Raw::Types;
use GTK::Clutter::Raw::Types;

use Clutter::Actor;
use Clutter::AlignConstraint;
use Clutter::Image;

use GTK::Application;
use GTK::Box;
use GTK::IconTheme;
use GTK::Image;
use GTK::Notebook;
use GTK::Window;

use GTK::Clutter::Embed;
use GTK::Clutter::Main;

my %globals;

sub create-tex($stage, $icon) {
  my $theme = GTK::IconTheme.get-default;
  my $is-info = $icon.ends-with('information');
  my $pixbuf = $theme.load-icon(
    $icon,
    $is-info ?? GTK_ICON_SIZE_DIALOG !! GTK_ICON_SIZE_BUTTON,
    GTK_ICON_LOOKUP_USE_BUILTIN
  );
  my $i = GTK::Image.new-from-pixbuf($pixbuf);
  %globals<vbox>.add($i);
  (my $image = Clutter::Image.new).set-data(
    $pixbuf.pixels,
    $pixbuf.has_alpha ??
      COGL_PIXEL_FORMAT_RGBA_8888 !! COGL_PIXEL_FORMAT_RGB_888,
    $pixbuf.width,
    $pixbuf.height,
    $pixbuf.rowstride
  );
  my $tex = do {
    my %data = ( content => $image );
    if $is-info {
      %data<position> = [ 160 - $pixbuf.width / 2, 120 - $pixbuf.height / 2 ]
    } else {
      %data<constraint> = Clutter::AlignConstraint.new(
        $stage, CLUTTER_ALIGN_BOTH, 0.5
      );
    }

    Clutter::Actor.new.setup(|%data);
  };
  $tex.show;
  $stage.add-child($tex);
}

sub MAIN {
  exit(1) unless GTK::Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  my @clutter;
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
  $window.destroy-signal.tap({ GTK::Application.quit });
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
