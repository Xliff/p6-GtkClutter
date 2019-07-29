use v6.c;

use Method::Also;

use NativeCall;

use GTK::Compat::Types;
use GTK::Clutter::Raw::Types;

use GTK::Raw::Utils;

class GTK::Clutter::Main {

  method get_option_group is also<get-option-group> {
    gtk_clutter_get_option_group();
  }

  multi method init {
    samewith(0, CArray[Str]);
  }
  multi method init (Int() $argc, CArray[Str] $argv) {
    my $c = resolve-int($argc);
    gtk_clutter_init($argc, $argv);
  }

  method init_with_args (
    Int() $argc,
    CArray[Str] $argv,
    Str $parameter_string,
    GOptionEntry $entries,
    Str $translation_domain,
    CArray[Pointer[GError]] $error = gerror
  )
    is also<init-with-args>
  {
    my $c = resolve-int($argc);
    clear_error;
    my $rc = gtk_clutter_init_with_args(
      $c,
      $argv,
      $parameter_string,
      $entries,
      $translation_domain,
      $error
    );
    set_error($error);
    $rc;
  }

}

sub gtk_clutter_get_option_group ()
  returns GOptionGroup
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_init (gint $argc, CArray[Str] $argv)
  returns gint # ClutterInitError
  is native(gtk-clutter)
  is export
{ * }

sub gtk_clutter_init_with_args (
  gint $argc,
  CArray[CArray[Str]] $argv,
  Str $parameter_string,
  GOptionEntry $entries,
  Str $translation_domain,
  CArray[Pointer[GError]] $error
)
  returns gint # ClutterInitError
  is native(gtk-clutter)
  is export
{ * }
