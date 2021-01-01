# frozen_string_literal: true

require 'gtk3'
require 'json'

module JsonView
  class ApplicationWindow < Gtk::ApplicationWindow
    type_register

    def self.init
      set_template resource: '/com/github/kojix2/jsonview/jsonview.ui'
      bind_template_child 'treeview'
      set_connect_func do |handler_name|
        lambda do
          JsonView.application.active_window.__send__(handler_name)
        end
      end
    end

    def initialize(application)
      super application: application
      set_title 'JsonView'
      set_icon GdkPixbuf::Pixbuf.new(
        resource: '/com/github/kojix2/jsonview/ruby.png'
      )
    end

    def on_open_clicked
      dialog = Gtk::FileChooserDialog.new(
        title: 'Gtk::FileChooser sample',
        action: :open,
        flags: :modal,
        buttons: [[Gtk::Stock::OPEN, :accept],
                  [Gtk::Stock::CANCEL, :cancel]]
      )
      Gtk::FileFilter.new.tap do |f|
        f.name = 'Json'
        f.add_pattern('*.json')
        dialog.add_filter f
      end
      Gtk::FileFilter.new.tap do |f|
        f.name = 'All'
        f.add_pattern('*')
        dialog.add_filter f
      end

      case dialog.run
      when Gtk::ResponseType::ACCEPT
        open_json(dialog.filename)
        dialog.destroy
      when Gtk::ResponseType::CANCEL
        dialog.destroy
      end
    end

    def open_json(filename)
      data = File.open(filename) do |file|
        JSON.load(file)
      end
      @model&.destroy
      @model = Gtk::TreeStore.new(String, Float)
      create_model(data)
      treeview.model = @model

      column = Gtk::TreeViewColumn.new(
        File.basename(filename),
        Gtk::CellRendererText.new,
        {
          text: 0,
          scale: 1
        }
      )
      treeview.append_column(column)
    end

    def create_model(data, parent = nil, size = 1.0)
      parent ||= @model.append(nil)
      case data
      when Hash
        data.each do |key, value|
          i = @model.append(parent)
          i[0] = key.to_s
          i[1] = size
          create_model(value, i, size * 0.9)
        end
      when Array
        data.each do |value|
          i = @model.append(parent)
          i[0] = ''
          i[1] = size
          create_model(value, i, size * 0.9)
        end
      when String, Numeric, Integer
        @model.append(parent).tap do |j|
          j[0] = data.to_s
          j[1] = size * 0.9
        end
      end
    end
  end
end
