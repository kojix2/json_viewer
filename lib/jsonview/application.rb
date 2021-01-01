# frozen_string_literal: true

require 'gtk3'

module JsonView
  class << self
    def application
      @@application ||= Gtk::Application.new('com.github.kojix2.jsonview', :flags_none)
    end
  end
end
