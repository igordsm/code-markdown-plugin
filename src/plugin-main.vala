/*
 * Copyright (c) 2011 Lucas Baudin <xapantu@gmail.com>
 *
 * This is a free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the
 * License, or (at your option) any later version.
 *
 * This is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; see the file COPYING.  If not,
 * write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA.
 *
 */

 public class MarkdownActions : Peas.ExtensionBase, Peas.Activatable {
    Scratch.Widgets.SourceView current_source;
    Scratch.Services.Interface plugins;

    public Object object { owned get; construct; }

    public void update_state () {}

    public void activate () {
        plugins = (Scratch.Services.Interface) object;
        plugins.hook_document.connect ((doc) => {
            if (current_source != null) {
                current_source.key_press_event.disconnect (shortcut_handler);
                current_source.notify["language"].disconnect (configure_shortcuts);
            }

            current_source = doc.source_view;
            configure_shortcuts ();

            current_source.notify["language"].connect (configure_shortcuts);
        });
    }

    private void configure_shortcuts () {
        var lang = current_source.language;
        if (lang != null && lang.id == "markdown") {
            current_source.key_press_event.connect (shortcut_handler);
        } else {
            current_source.key_press_event.disconnect (shortcut_handler);
        }
    }

    private bool shortcut_handler (Gdk.EventKey evt) {
        var control = (evt.state & Gdk.ModifierType.CONTROL_MASK) != 0;
        var shift = (evt.state & Gdk.ModifierType.SHIFT_MASK) != 0;
        var other_mods = (evt.state & Gtk.accelerator_get_default_mod_mask () &
                          ~Gdk.ModifierType.SHIFT_MASK &
                          ~Gdk.ModifierType.CONTROL_MASK) != 0;

        if (evt.is_modifier == 1 || other_mods == true) {
            return false;
        }

        if (control && shift) {
            switch (evt.keyval) {
                case Gdk.Key.B:
                    add_markdown_tag ("**");
                    return true;
                case Gdk.Key.I:
                    add_markdown_tag ("_");
                    return true;
                case Gdk.Key.K:
                    insert_link ();
                    break;
            }
        }

        return false;
    }

    private void insert_link () {
        var current_buffer = current_source.buffer;
        if (current_buffer.has_selection) {
            insert_around_selection ("[", "]");
            current_buffer.insert_at_cursor ("()", 2);
            go_back_n_chars (1);
        } else {
            current_buffer.insert_at_cursor ("[]", 2);
            current_buffer.insert_at_cursor ("()", 2);
            go_back_n_chars (3);
        }
    }

    private void go_back_n_chars (int back_chars) {
        Gtk.TextIter insert_position;
        var current_buffer = current_source.buffer;
        current_buffer.get_iter_at_offset (out insert_position, current_buffer.cursor_position - back_chars);
        current_buffer.place_cursor (insert_position);
    }

    private void insert_around_selection (string before, string after) {
        Gtk.TextIter start, end;
        var current_buffer = current_source.buffer;
        current_buffer.get_selection_bounds (out start, out end);
        var mark_end = new Gtk.TextMark (null);
        current_buffer.add_mark (mark_end, end);
        current_buffer.place_cursor (start);
        current_buffer.insert_at_cursor (before, before.length);

        current_buffer.get_iter_at_mark (out end, mark_end);
        current_buffer.place_cursor (end);
        current_buffer.insert_at_cursor (after, after.length);
    }

    public void add_markdown_tag (string tag) {
        var current_buffer = current_source.buffer;
        if (current_buffer.has_selection) {
            insert_around_selection (tag, tag);
        } else {
            current_buffer.insert_at_cursor (tag, tag.length);
            current_buffer.insert_at_cursor (tag, tag.length);
        }
        go_back_n_chars (tag.length);
    }

    public void deactivate () {
        if (current_source != null) {
            current_source.key_press_event.disconnect (shortcut_handler);
            current_source.notify["language"].disconnect (configure_shortcuts);
        }
    }

}

[ModuleInit]
public void peas_register_types (GLib.TypeModule module) {
    var objmodule = module as Peas.ObjectModule;
    objmodule.register_extension_type (typeof (Peas.Activatable),
                                       typeof (MarkdownActions));
}
