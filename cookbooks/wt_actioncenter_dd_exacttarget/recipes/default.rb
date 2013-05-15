#
# Cookbook Name:: wt_actioncenter_dd_exacttarget
# Recipe:: default
#
# Copyright 2012, Webtrends
#
# All rights reserved - Do Not Redistribute
#

if ENV["deploy_build"] == "true" then
  log "The deploy_build value is true so un-deploying first"
  include_recipe "wt_actioncenter_dd_exacttarget::undeploy"
else
  log "The deploy_build value is not set or is false so we will only update the configuration"
end
auth_data = data_bag_item('authorization',node.chef_environment)
install_dir  = File.join(node['wt_portfolio_harness']['plugin_dir'], "exacttarget")
conf_dir     = File.join(install_dir, "conf")
tarball      = node['wt_actioncenter_dd_exacttarget']['download_url'].split("/")[-1]
download_url = node['wt_actioncenter_dd_exacttarget']['download_url']
user         = node['wt_actioncenter_dd_exacttarget']['user']
group        = node['wt_actioncenter_dd_exacttarget']['group']
ads_host     = URI(node['wt_streamingconfigservice']['config_service_url']).host
authToken    = auth_data['wt_streamingconfigservice']['authToken']
ads_ssl_port = node['wt_streamingconfigservice']['config_service_ssl_port']
datarequest_max_event_batch_time_ms = node['wt_actioncenter_dd_exacttarget']['datarequest_max_event_batch_time_ms']
datarequest_max_events_in_batch = node['wt_actioncenter_dd_exacttarget']['datarequest_max_events_in_batch']
datarequest_failure_delay_before_retry_ms = node['wt_actioncenter_dd_exacttarget']['datarequest_failure_delay_before_retry_ms']
datarequest_nodata_delay_before_retry_ms = node['wt_actioncenter_dd_exacttarget']['datarequest_nodata_delay_before_retry_ms']
sender_max_send_retries = node['wt_actioncenter_dd_exacttarget']['sender_max_send_retries']
sender_min_exponential_backoff_delay_ms = node['wt_actioncenter_dd_exacttarget']['sender_min_exponential_backoff_delay_ms']
sender_max_delay_before_dropping_data_ms = node['wt_actioncenter_dd_exacttarget']['sender_max_delay_before_dropping_data_ms']
testing_enabled = node['wt_actioncenter_dd_exacttarget']['testing_enabled']
testing_key_column_override = node['wt_actioncenter_dd_exacttarget']['testing_key_column_override']
proxy_uri = node['wt_common']['http_proxy_url']


log "Install dir: #{install_dir}"

# create the directories
[install_dir, conf_dir].each do |dir|
  directory dir do
    owner "root"
    group "root"
    mode 00755
    recursive true
    action :create
  end
end

if node.recipes.include?("wt_actioncenter_ddp") then
	# Optimization : there is no need to go thru proxy if we can access partner endpoints directly from DDP box
	# All other boxes behind the load balancer must go through proxy
	proxy_uri = ""
end

if ENV["deploy_build"] == "true" then
  log "The deploy_build value is true so we will grab the tar ball and install"

  # download the application tarball
  remote_file "#{Chef::Config[:file_cache_path]}/#{tarball}" do
    source download_url
    mode 00644
  end

    # uncompress the application tarball into the install dir
  execute "tar" do
    user  "root"
    group "root"
    cwd install_dir
    command "tar zxf #{Chef::Config[:file_cache_path]}/#{tarball}"
    notifies :restart, "service[harness]", :delayed
  end

  # delete the install tar ball
  execute "delete_install_source" do
    user "root"
    group "root"
    command "rm -f #{Chef::Config[:file_cache_path]}/#{tarball}"
    action :run
  end
end

%w[config.properties exacttarget.conf].each do | template_file|
  template "#{conf_dir}/#{template_file}" do
    source "#{template_file}.erb"
    owner "root"
    group "root"
    mode 00644
    variables({
      :config_host => ads_host,
      :authToken => authToken,
      :secure_config_host => ads_host,
      :secure_config_port => ads_ssl_port,
      :datarequest_max_event_batch_time_ms => datarequest_max_event_batch_time_ms,
      :datarequest_max_events_in_batch => datarequest_max_events_in_batch,
      :datarequest_failure_delay_before_retry_ms => datarequest_failure_delay_before_retry_ms,
      :datarequest_nodata_delay_before_retry_ms => datarequest_nodata_delay_before_retry_ms,
      :sender_max_send_retries => sender_max_send_retries,
      :sender_min_exponential_backoff_delay_ms => sender_min_exponential_backoff_delay_ms,
      :sender_max_delay_before_dropping_data_ms => sender_max_delay_before_dropping_data_ms,
      :testing_enabled => testing_enabled,
      :testing_key_column_override => testing_key_column_override,
      :proxy_uri => proxy_uri
    })
    notifies :restart, "service[harness]", :delayed
  end
end