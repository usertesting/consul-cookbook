#
# Cookbook: consul
# License: Apache 2.0
#
# Copyright 2014-2016, Bloomberg Finance L.P.
#
include_recipe 'chef-sugar::default'

unless windows?
  group node['consul']['service_group'] do
    system true
  end

  user node['consul']['service_user'] do
    shell '/bin/bash'
    group node['consul']['service_group']
    system true
  end
end

service_name = node['consul']['service_name']
config = consul_config service_name do |r|
  owner node['consul']['service_user']
  group node['consul']['service_group']
  node['consul']['config'].each_pair { |k, v| r.send(k, v) }
  notifies :reload, "consul_service[#{service_name}]", :delayed
end

consul_installation "Consul WebUI: #{node['consul']['version']}" do
  provider :webui
  version node['consul']['version']
  options symlink_to: config.ui_dir if config.ui_dir
  only_if { config.ui == true }
end

install = consul_installation node['consul']['version'] do |r|
  if node['consul']['installation']
    node['consul']['installation'].each_pair { |k, v| r.send(k, v) }
  end
end

consul_service service_name do |r|
  version node['consul']['version']
  config_file config.path
  program install.consul_program

  user node['consul']['service_user']
  group node['consul']['service_group']

  if node['consul']['service']
    node['consul']['service'].each_pair { |k, v| r.send(k, v) }
  end
end
