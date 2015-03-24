include_attribute 'java'

default['java']['install_flavor'] = 'openjdk'
default['java']['openjdk_packages'] = ['openjdk-7-jre-headless', 'openjdk-7-jdk']
default['java']['jdk_version'] = '7'

default['artifactory']['version'] = '3.5.1'
default['artifactory']['checksum'] = 'b6ae87d5ce044975af9965ac833c91e9c64b9ece3ececb59007a3c33749367e4'
default['artifactory']['user'] = 'artifactory'
default['artifactory']['dir'] = '/opt/artifactory'
default['artifactory']['java_opts'] = '-server -Xms512m -Xmx2g -Xss256k -XX:PermSize=128m -XX:MaxPermSize=128m -XX:+UseG1GC'

node.set['artifactory']['url'] = "http://dl.bintray.com/content/jfrog/artifactory/artifactory-#{node['artifactory']['version']}.zip?direct"

default['artifactory']['tomcat']['home']                      = "#{node['artifactory']['dir']}/tomcat"
default['artifactory']['catalina']['home']                    = "#{node['artifactory']['dir']}/tomcat"
default['artifactory']['catalina']['port']                    = 8081
default['artifactory']['catalina']['protocol']                = 'HTTP/1.1'
default['artifactory']['catalina']['max_threads']             = 500
default['artifactory']['catalina']['min_spare_threads']       = 20
default['artifactory']['catalina']['max_spare_threads']       = 150
default['artifactory']['catalina']['enable_lookups']          = false
default['artifactory']['catalina']['disable_upload_timeout']  = true
default['artifactory']['catalina']['backlog']                 = 100

