use v6;

use CompUnit::Util :re-export;

use GLib::Raw::Exports;
use Pango::Raw::Exports;
use GDK::Raw::Exports;
use GTK::Raw::Exports;
use COGL::Raw::Exports;
use Clutter::Raw::Exports;
use GTK::Clutter::Raw::Exports;

unit package GTK::Clutter::Raw::Types;

need Cairo;
need GLib::Raw::Definitions;
need GLib::Raw::Enums;
need GLib::Raw::Object;
need GLib::Raw::Structs;
need GLib::Raw::Struct_Subs;
need GLib::Raw::Subs;
need Pango::Raw::Definitions;
need Pango::Raw::Enums;
need Pango::Raw::Structs;
need Pango::Raw::Subs;
need GDK::Raw::Definitions;
need GDK::Raw::Enums;
need GDK::Raw::Structs;
need GDK::Raw::Subs;
need GTK::Raw::Definitions;
need GTK::Raw::Enums;
need GTK::Raw::Structs;
need GTK::Raw::Subs;
need GTK::Raw::Requisition;
need COGL::Raw::Definitions;
need COGL::Raw::Enums;
need COGL::Raw::Structs;
need COGL::Compat::Types;
need Clutter::Raw::Definitions;
need Clutter::Raw::Enums;
need Clutter::Raw::Exceptions;
need Clutter::Raw::Structs;
need GTK::Clutter::Raw::Definitions;

BEGIN {
  re-export($_) for
    |@glib-exports,
    |@cogl-exports,
    |@pango-exports,
    |@gdk-exports,
    |@gtk-exports,
    |@clutter-exports,
    |@gtk-clutter-exports;
}
