require 'rake'

module FancyPutter

  COLORS = %w[black red green yellow blue magenta cyan white]
  COLORS.each_with_index do |color, i|
    define_method(color.to_sym) do |str|
      wrapper(i, str)
    end
  end

  private

  def wrapper(color_code, str)
    "\033[3#{color_code}m#{str}\033[0m"
  end

end

module Installer
  include FancyPutter

  PATH = File.dirname(File.realdirpath(__FILE__))
  HOME = Dir.home

  def files_in_dir(dir)
    Dir.open(dir).entries.reject { |f| f =~ /^\.{1,2}$/ }
  end

  def install
    files = `find #{PATH}/home -type f`.split("\n")
    files.each do |file|
      target = "#{HOME}/#{convert_dot_path(file)}"
      if File.exists?(target)
        puts yellow "  Target file already exists: #{target}"
        if diff = `diff #{file} #{target}` and !diff.empty?
          puts red "  There was a conflict with:  #{target}"
          puts diff
        end
      else
        %x(ln -s #{file} #{target})
        puts green "  linked #{target}"
      end
    end
  end

  private

  # returns what the relative path target to the home directory
  def convert_dot_path(path)
    local_path = path.slice("#{PATH}/home/".length..-1)
    local_path.gsub!(/dot\-/, '.')
    local_path
  end
end

desc "Install dot files"
task :install do
  include Installer
  Installer.install
end
task default: :install

namespace :test do
  task :colortest do
    include FancyPutter
    puts "Oooooh pretty"
    COLORS.each { |c| puts send(c.to_sym, c) }
  end
end

