/*
* Copyright 2019 elementary, Inc. (https://elementary.io)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class Tasks.TaskRow : Gtk.ListBoxRow {
    public unowned ICal.Component component { get; construct; }

    private static Gtk.CssProvider taskrow_provider;

    public bool completed { get; private set; }

    public TaskRow (ICal.Component component) {
        Object (component: component);
    }

    static construct {
        taskrow_provider = new Gtk.CssProvider ();
        taskrow_provider.load_from_resource ("io/elementary/tasks/TaskRow.css");
    }

    construct {
        completed = component.get_status () == ICal.PropertyStatus.COMPLETED;

        var check = new Gtk.CheckButton ();
        check.active = completed;
        check.sensitive = false;

        var summary_label = new Gtk.Label (component.get_summary ());
        summary_label.justify = Gtk.Justification.LEFT;
        summary_label.wrap = true;
        summary_label.xalign = 0;

        if (completed) {
            summary_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);
        }

        var horizontal_box = new Gtk.HBox (false, 3);
        var grid = new Gtk.Grid ();
        grid.margin = 3;
        grid.margin_start = grid.margin_end = 24;
        grid.column_spacing = 6;
        grid.add (check);

        var due = component.get_due ();
        if (!due.is_null_time ()) {
            GLib.TimeZone due_timezone = null;
            if (due.get_tzid () != null) {
                due_timezone = new GLib.TimeZone (due.get_tzid ());
            } else {
                due_timezone = new GLib.TimeZone.local();
            }

            var due_datetime = new GLib.DateTime (
                due_timezone,
                due.year,
                due.month,
                due.day,
                due.hour,
                due.minute,
                due.second
            );

            var due_label = new Gtk.Label (Granite.DateTime.get_relative_datetime (due_datetime));
            due_label.wrap = true;

            var due_box = new Gtk.EventBox ();
            Gdk.Color color;
            Gdk.Color.parse ("lightgray", out color);
            due_box.modify_bg (Gtk.StateType.NORMAL, color);

            /* does not seem to work:
            var due_box_style_context = due_box.get_style_context ();
            due_box_style_context.add_class ("due-date");
            due_box_style_context.add_provider (taskrow_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
            */

            due_box. add (due_label);
            horizontal_box.pack_start (due_box, false);
        }

        horizontal_box.pack_start (summary_label, false);
        grid.add (horizontal_box);

        var description = component.get_description ();
        if (description != null) {
            description = description.replace ("\r", "").strip ();
            string[] lines = description.split ("\n");
            string stripped_description = lines[0].strip ();
            for (int i = 1; i < lines.length; i++) {
                string stripped_line = lines[i].strip ();

                if (stripped_line.length > 0 ) {
                    stripped_description += " " + lines[i].strip ();
                }
            }

            if (stripped_description.length > 0) {
                var description_label = new Gtk.Label (stripped_description);
                description_label.xalign = 0;
                description_label.lines = 1;
                description_label.ellipsize = Pango.EllipsizeMode.END;
                description_label.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

                grid.attach_next_to (description_label, horizontal_box, Gtk.PositionType.BOTTOM);
            }
        }

        add (grid);
    }
}
