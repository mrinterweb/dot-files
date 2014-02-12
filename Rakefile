require 'rake'

module Installer
  PATH = File.dirname(File.realdirpath(__FILE__))
  HOME = Dir.home

  def files_in_dir(dir)
    Dir.open(dir).entries.reject { |f| f =~ /^\.{1,2}$/ }
  end

  def install
    files_in_dir(PATH+"/dot").each do |file|
      if File.exists?("#{HOME}/.#{file}")
        puts "  skipping #{file}. Already exists"
      else
        %x(ln -s #{PATH}/dot/#{file} #{HOME}/.#{file})
        puts "  linked #{HOME}/.#{file}"
      end
    end
  end
end

desc "Install dot files"
task :install do
  include Installer
  Installer.install
end

task default: :install
