if node['artifactory']['database']['type'].upcase == "MYSQL"
  include_recipe "artifactory::mysql"
end
