# NOTE: Must run these before a newer version of the Artifactory is deployed
# (before an upgrade)
# Needs to delete these contents as they are needed to be replaced during an
# upgrade.
# We follow the guide from JFrog for upgrade process:
# http://www.jfrog.com/confluence/display/RTF/Upgrading+Artifactory
files_to_replace = ['webapps/artifactory.war']
folders_to_replace = ['tomcat', 'bin']

files_to_replace.each do |item|
  file "#{node['artifactory']['dir']}/#{item}" do
    action :delete
    notifies :put, "ark[artifactory]", :delayed
  end
end

folders_to_replace.each do |item|
  directory "#{node['artifactory']['dir']}/#{item}" do
    recursive true
    action :delete
    notifies :put, "ark[artifactory]", :delayed
  end
end


