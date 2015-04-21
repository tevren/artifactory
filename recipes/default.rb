
include_recipe 'apt::default'
include_recipe 'java::default'

package 'unzip'

user node['artifactory']['user'] do
  home node['artifactory']['dir']
end

ark 'artifactory' do
  action :put
  url node['artifactory']['url']
  checksum node['artifactory']['checksum']
  path File.dirname(node['artifactory']['dir'])
  owner node['artifactory']['user']
  group node['artifactory']['user']
end

include_recipe "artifactory::_database"
include_recipe "artifactory::_tomcat"

# A quick fix for some bad ACL after unzipping the pro artifactory .zip
# Not all *.sh are packaged with proper executable permission.
#
execute "change-executable-permission" do
  command "find #{node['artifactory']['dir']} -type f -name '*.sh' -exec chmod +x {} \\;"
  user "root"
  notifies :restart, 'service[artifactory]', :delayed
end

case node['artifactory']['init_service']
when 'runit'
  include_recipe 'runit::default'
  runit_service 'artifactory' do
    default_logger true
    env({
          "CATALINA_OPTS" => [
                              node['artifactory']['java_opts'],
                              "-Dfile.encoding=UTF8",
                              "-Dartifactory.home=#{node['artifactory']['dir']}"
                             ].join(" "),
          "ARTIFACTORY_HOME" => node['artifactory']['dir']
        })
    subscribes :restart, "template [#{node['artifactory']['dir']}/etc/storage.properties]", :delayed
  end
when 'upstart'
  template '/etc/init/artifactory.conf' do
    source 'artifactory.conf.erb'
    variables(env:{
          "CATALINA_OPTS" => [
                              node['artifactory']['java_opts'],
                              "-Dfile.encoding=UTF8",
                              "-Dartifactory.home=#{node['artifactory']['dir']}"
                             ].join(" "),
          "ARTIFACTORY_HOME" => node['artifactory']['dir']
        })
    owner 'root'
    group 'root'
    mode '0644'
  end
  
  service 'artifactory' do
    provider Chef::Provider::Service::Upstart
    supports :status => true, :restart => true
    action [ :start, :enable ]
    subscribes :restart, "template [#{node['artifactory']['dir']}/etc/storage.properties]", :delayed
  end
end