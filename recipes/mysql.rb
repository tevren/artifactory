# Download the JDBC lib jar
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
  notifies :create, "template[#{node['artifactory']['dir']}/etc/storage.properties]", :delayed
end

# Install MySQL client
mysql_client 'default' do
  action :create
  notifies :install, 'chef_gem[mysql2]', :immediately
end

# NOTE: database cookbook required to use 'mysql2' gem to be installed
chef_gem "mysql2" do
  action :install
end

# Install the MySQL server on the same box
template '/etc/mysql/conf.d/artifactory.cnf' do
  owner node['artifactory']['user']
  group node['artifactory']['user']
  source 'artifactory.cnf.erb'
  notifies :restart, 'mysql_service[default]'
end

mysql_service 'default' do
  version '5.5'
  action :create
end

# Setting up artifactory db
mysql_connection_info = {
  :host =>  node['mysql']['bind_address'],
  :username => "root",
  :password => node['mysql']['server_root_password']
}

mysql_database node['artifactory']['database']['name'] do
  connection mysql_connection_info
  action :create
end

mysql_database "changing the charset of database" do
  connection mysql_connection_info
  database_name node['artifactory']['database']['name']
  action :query
  sql "ALTER DATABASE #{node['artifactory']['database']['name']} charset=utf8"
end

mysql_database_user node['artifactory']['database']['username'] do
  connection mysql_connection_info
  database_name node['artifactory']['database']['name']
  password node['artifactory']['database']['password']
  privileges [
    :all
  ]
  action :grant
end

mysql_database "flushing mysql privileges" do
  connection mysql_connection_info
  action :query
  sql "FLUSH PRIVILEGES"
  notifies :create, "template[#{node['artifactory']['dir']}/etc/storage.properties]", :delayed
end

# Required to setup the JDBC MySQL connection from Artifactory to MySQL DB
template "#{node['artifactory']['dir']}/etc/storage.properties" do
  owner node['artifactory']['user']
  group node['artifactory']['user']
  source 'storage/mysql.properties.erb'
  notifies :restart, 'service[artifactory]'
end
