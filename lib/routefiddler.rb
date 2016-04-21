require 'require_all'

require_rel '.'

# Routefiddler
module Routefiddler
  class << self
    attr_accessor :configure, :filter, :options
  end

  def self.configure(options = {})
    self.options = options

    self
  end

  def self.update
    self.options ||= {}

    Routefiddler::Route::Update.new(self.options).update
  end
end
