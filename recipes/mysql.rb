directory "#{node['artifactory']['dir']}/tomcat/lib" do
  mode '0775'
  owner node['artifactory']['user']
  action :create
  recursive true
  notifies :create, "remote_file[#{node['artifactory']['dir']}/tomcat/lib/mysql-connector-java-5.1.21.jar]", :immediately
end

remote_file "#{node['artifactory']['dir']}/tomcat/lib/mysql-connector-java-5.1.21.jar" do
  source "https://repo1.maven.org/maven2/mysql/mysql-connector-java/5.1.21/mysql-connector-java-5.1.21.jar"
  checksum "7abbd19fc2e2d5b92c0895af8520f7fa30266be9"
  owner node['artifactory']['user']
  mode '0644'
end
