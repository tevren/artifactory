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
  notifies :install, 'mysql2_chef_gem[default]', :immediately
end

# NOTE: database cookbook required to use 'mysql2' gem to be installed
mysql2_chef_gem 'default' do
  action :install
end

# Install the MySQL server on the same box
mysql_creds = Chef::EncryptedDataBagItem.load(node['mysql']['databag'], node['mysql']['databag_item'])
mysql_service 'artifactory' do
  version '5.5'
  bind_address '0.0.0.0'
  port '3306'
  data_dir '/data'
  initial_root_password mysql_creds['server_root_password']
  action [:create, :start]
end

mysql_config 'artifactory' do
  instance 'artifactory'
  source 'artifactory.cnf.erb'
  action :create
  notifies :restart, 'mysql_service[artifactory]'
end

# Setting up artifactory db
mysql_connection_info = {
  :host =>  node['mysql']['bind_address'],
  :username => "root",
  :password => mysql_creds['server_root_password']
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

artifactory_creds = Chef::EncryptedDataBagItem.load(node['artifactory']['databag'], node['artifactory']['databag_item'])

mysql_database_user artifactory_creds['mysql']['username'] do
  connection mysql_connection_info
  database_name node['artifactory']['database']['name']
  password artifactory_creds['mysql']['password']
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
  variables(:artifactory_creds => artifactory_creds)
  source 'storage/mysql.properties.erb'
end
