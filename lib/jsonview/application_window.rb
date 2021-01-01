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

    def initialize(application, argv)
      super application: application
      set_title 'JsonView'
      argv[0] && open_json(argv[0])
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
        f.add_pattern('*.JSON')
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
      @treemodel&.destroy
      @treemodel = Gtk::TreeStore.new(String, Float, String)
      create_model(data)
      treeview.model = @treemodel

      column = Gtk::TreeViewColumn.new(
        File.basename(filename),
        Gtk::CellRendererText.new,
        { text: 0, scale: 1, foreground: 2 }
      )
      treeview.append_column(column)
    end

    def create_model(data, parent = nil, level = 0)
      parent ||= @treemodel.append(nil)
      case data
      when Hash
        data.each do |key, value|
          i = @treemodel.append(parent)
          i[0] = key.to_s
          i[1] = 1.0 # drate ** level
          create_model(value, i, level + 1)
        end
      when Array
        data.each do |value|
          i = @treemodel.append(parent)
          i[0] = ''
          i[1] = 1.0 # drate ** level
          create_model(value, i, level + 1)
        end
      when String
        level += 1
        @treemodel.append(parent).tap do |j|
          j[0] = data
          j[1] = 1.0 # drate ** level
        end
      when Numeric, Integer
        level += 1
        @treemodel.append(parent).tap do |j|
          j[0] = data.to_s
          j[1] = 1.0 # drate ** level
          j[2] = 'yellow'
        end
      when true
        level += 1
        @treemodel.append(parent).tap do |j|
          j[0] = data.to_s
          j[1] = 1.0 # drate ** level
          j[2] = 'magenta'
        end
      when false
        level += 1
        @treemodel.append(parent).tap do |j|
          j[0] = data.to_s
          j[1] = 1.0 # drate ** level
          j[2] = ''
        end
      else
        level += 1
        @treemodel.append(parent).tap do |j|
          j[0] = data.to_s
          j[1] = 1.0 # drate ** level
          j[2] = 'lime'
        end
      end
    end
  end
end
