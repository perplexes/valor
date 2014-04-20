#!/usr/bin/env ruby
require 'json'
require 'pry'
require 'active_support'

root = File.expand_path('../..', __FILE__)
meta = {
  images: ActiveSupport::OrderedHash.new,
  sounds: ActiveSupport::OrderedHash.new,
  fonts: ActiveSupport::OrderedHash.new
}

Dir[root + '/assets/shared/graphics/*'].sort_by{|f| File.basename(f)}.each do |file|
  file_meta = `file #{file}`.chomp
  _, width, height = file_meta.match(/(\d+) x (\d+)/).to_a
  nick = File.basename(file).split('.').first
  meta[:images][nick] = {
    url: file.sub(root + '/', ''),
    width: width.to_i,
    height: height.to_i
  }
end

Dir[root + '/assets/shared/sounds/*'].sort_by{|f| File.basename(f)}.each do |file|
  nick = File.basename(file).split('.').first
  meta[:sounds][nick] = {
    url: file.sub(root + '/', '')
  }
end

Dir[root + '/assets/shared/fonts/*'].sort_by{|f| File.basename(f)}.each do |file|
  nick = File.basename(file).split('.').first
  meta[:fonts][nick] = {
    url: file.sub(root + '/', '')
  }
end


puts JSON.pretty_generate(meta)