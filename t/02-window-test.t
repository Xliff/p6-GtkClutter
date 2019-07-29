use v6.c;

use GTK::Compat::Types;
use GTK::Raw::Types;
use Clutter::Raw::Types;

use GTK::Compat::Value;

use GTK::Application;
use GTK::IconView;
use GTK::IconTheme;
use GTK::ListStore;
use GTK::ScrolledWindow;
use GTK::Toolbar;
use GTK::ToolButton;

use Clutter::Actor;
use Clutter::BindConstraint;
use Clutter::Stage;

use GTK::Clutter::Actor;
use GTK::Clutter::Main;
use GTK::Clutter::Window;

sub add-liststore-rows($store, *@icon-names) {
  my $theme = GTK::IconTheme.get-default;
  for @icon-names -> $icon {
    my $pixbuf = $theme.load-icon($icon, 48, 0);
    my %data = (
      0 => GTK::Compat::Value.new(G_TYPE_STRING),
      1 => GTK::Compat::Value.new(G_TYPE_OBJECT)
    );
    %data<0>.string = $icon;
    %data<1>.object = $pixbuf // GdkPixbuf;
    my $iter = $store.append;
    $store.set-value( $iter, $_, %data{$_} ) for %data.keys;
  }
}

sub add-toolbar-items($toolbar, *@icon-names) {
  for @icon-names -> $icon {
    my $item = GTK::ToolButton.new;
    $item.icon-name = $icon;
    $item.set-tooltip-text($icon);
    $toolbar.insert($item);
  }
}

sub on-toolbar-enter($a, $e, $d, $r) {
  CATCH { default { .message.say } }

  $a.save-easing-state;
  $a.easing-mode = CLUTTER_LINEAR;
  ($a.opacity, $a.y) = (255, 0);
  $a.restore-easing-state;
  $r.r = CLUTTER_EVENT_STOP;
}

sub on-toolbar-leave($a, $e, $d, $r) {
  CATCH { default { .message.say } }

  $a.save-easing-state;
  $a.easing-mode = CLUTTER_LINEAR;
  ($a.opacity, $a.y) = (128, $a.height * -0.5);
  $a.restore-easing-state;
  $r.r = CLUTTER_EVENT_STOP;
}

sub MAIN {
  exit(1) unless GTK::Clutter::Main.init == CLUTTER_INIT_SUCCESS;

  my $window = GTK::Clutter::Window.new;
  $window.destroy-signal.tap({ GTK::Application.quit });
  $window.set-default-size(400, 300);

  my $store = GTK::ListStore.new(
    G_TYPE_STRING,
    GTK::Compat::Pixbuf.get_type
  );
  add-liststore-rows($store, |<
    devhelp
    empathy
    evince
    gnome-panel
    seahorse
    sound-juicer
    totem
  >);

  my $icon-view = GTK::IconView.new-with-model($store);
  ($icon-view.text-column, $icon-view.pixbuf-column) = ^2;

  my $sw = GTK::ScrolledWindow.new;
  $window.add($sw);
  $sw.add($icon-view);

  my $stage = $window.get-stage;
  my $toolbar = GTK::Toolbar.new;
  add-toolbar-items($toolbar, |<
    list-add
    format-text-bold
    format-text-italic
    media-optical
    edit-copy
  >);
  $toolbar.show-all;

  my $actor = GTK::Clutter::Actor.new-with-contents($toolbar);
  $actor.add-constraint(
    Clutter::BindConstraint.new($stage, CLUTTER_BIND_WIDTH, 0)
  );
  $actor.enter-event.tap(-> *@a { on-toolbar-enter(|@a) });
  $actor.leave-event.tap(-> *@a { on-toolbar-leave(|@a) });
  $actor.y = $actor.height * -0.5;
  ($actor.opacity, $actor.reactive) = (128, True);
  $stage.add-child($actor);
  $window.show-all;

  GTK::Application.main;
}
