name 'consul'
maintainer 'John Bellone'
maintainer_email 'jbellone@bloomberg.net'
license 'Apache 2.0'
description 'Application cookbook which installs and configures Consul.'
long_description 'Application cookbook which installs and configures Consul.'
version '2.1.1'

recipe 'consul::default', 'Installs and configures the Consul service.'
recipe 'consul::client_gem', 'Installs the Consul Ruby client as a gem.'

supports 'ubuntu', '>= 12.04'

depends 'build-essential'
depends 'chef-sugar'
depends 'golang'
depends 'poise', '~> 2.2'
depends 'poise-service', '~> 1.0'
depends 'rubyzip', '~> 1.3'

source_url 'https://github.com/johnbellone/consul-cookbook' if respond_to?(:source_url)
issues_url 'https://github.com/johnbellone/consul-cookbook/issues' if respond_to?(:issues_url)
