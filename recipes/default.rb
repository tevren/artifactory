include_recipe 'runit::default'
include_recipe 'apt::default'
include_recipe 'java::default'
 
user node['artifactory']['user'] do
  home node['artifactory']['dir']
end
 
package 'unzip'

# NOTE: Must run these before the unpacking step
# Needs to delete these contents as they are needed to be replaced during an
# upgrade.
# We follow the guide from JFrog for upgrade process:
# http://www.jfrog.com/confluence/display/RTF/Upgrading+Artifactory
files_to_replace = ['webapps/artifactory.war']
folders_to_replace = ['tomcat', 'bin']

files_to_replace.each do |item|
  file "#{node['artifactory']['dir']}/#{item}" do
    action :delete
  end
end

folders_to_replace.each do |item|
  directory "#{node['artifactory']['dir']}/#{item}" do
    recursive true
    action :delete
  end
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
end
