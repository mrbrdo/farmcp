require 'fileutils'

puts "Please enter your username (e.g. user):"
username = gets.strip
app_root = File.expand_path('../..', __FILE__)

def gsub_file(path, regexp, *args, &block)
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end

FileUtils.cp("#{app_root}/script/puma-init-d", "/etc/init.d/puma")
FileUtils.mkdir_p("/usr/local/bin")
FileUtils.cp("#{app_root}/script/puma-run", "/usr/local/bin/run-puma")
gsub_file('/etc/init.d/puma', /\/home\/user/, "/home/#{username}")
gsub_file('/usr/local/bin/run-puma', /\/home\/user/, "/home/#{username}")

conf = "#{app_root},#{username}"
File.open("/etc/puma.conf", "w") { |f| f.write(conf) }

puts "Do you want to run FarmCP on reboot? (yes/no)"
if gets.strip == "yes"
  system('update-rc.d -f puma defaults')
end

puts "Starting FarmCP..."
system('/etc/init.d/puma start')
