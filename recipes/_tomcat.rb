directory "#{node['artifactory']['catalina']['home']}/conf/Catalina/localhost" do
  mode '0755'
  owner node['artifactory']['user']
  group node['artifactory']['user']
  action :create
  recursive true
  notifies :create, "template[#{node['artifactory']['catalina']['home']}/conf/server.xml]", :delayed
  notifies :create, "template[#{node['artifactory']['tomcat']['home']}/conf/Catalina/localhost/artifactory.xml]", :delayed
end

# Write a new Catalina server configuration file
template "#{node['artifactory']['catalina']['home']}/conf/server.xml" do
  source 'server.xml.erb'
  owner node['artifactory']['user']
  mode 0664
  notifies :restart, 'service[artifactory]', :delayed
end

template "#{node['artifactory']['tomcat']['home']}/conf/Catalina/localhost/artifactory.xml" do
  source 'artifactory.xml.erb'
  owner node['artifactory']['user']
  mode 0664
  notifies :restart, 'service[artifactory]', :delayed
end


