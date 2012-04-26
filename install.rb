PATH = File.dirname(File.realdirpath(__FILE__))
HOME = Dir.home

%w[screenrc].each do |file|
  if File.exists?("#{HOME}/.#{file}")
    puts "  skipping #{file}. Already exists"
  else
    %x(ln -s #{PATH}/dot/#{file} #{HOME}/.#{file})
    puts "  linked #{HOME}/.#{file}"
  end
end

