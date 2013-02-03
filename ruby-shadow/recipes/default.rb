begin
	require 'shadow'
rescue LoadError
	ruby_location = RbConfig::CONFIG['prefix']
	Chef::Log.info("Installing ruby-shadow for password support...")
	if ruby_location.eql? "/opt/chef/embedded"
	  Chef::Log.info("Ruby location is #{ruby_location}, therefore I should use a local gem install instead")
	  # Install
	  include_recipe "build-essential"
	  gem_package "ruby-shadow"
	else
	  package "shadow_pkg" do
	    package_name "ruby-shadow"
	    action :install
	  end
	end
end