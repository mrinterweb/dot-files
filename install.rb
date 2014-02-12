PATH = File.dirname(File.realdirpath(__FILE__))
HOME = Dir.home

def files_in_dir(dir)
  Dir.open(dir).entries.reject { |f| f =~ /^\.{1,2}$/ }
end

files_in_dir(PATH+"/dot").each do |file|
  if File.exists?("#{HOME}/.#{file}")
    puts "  skipping #{file}. Already exists"
  else
    %x(ln -s #{PATH}/dot/#{file} #{HOME}/.#{file})
    puts "  linked #{HOME}/.#{file}"
  end
end

