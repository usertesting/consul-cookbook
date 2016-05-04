#
# Cookbook: consul
# License: Apache 2.0
#
# Copyright 2014-2016, Bloomberg Finance L.P.
#

module ConsulCookbook
  module Helpers # rubocop:disable Metrics/ModuleLength

    include Chef::Mixin::ShellOut

    extend self

    def arch_64?
      node['kernel']['machine'] =~ /x86_64/ ? true : false
    end

    # Simply using ::File.join was causing several attributes
    # to return strange values in the resources (e.g. "C:/Program Files/\\consul\\data")
    def join_path(*path)
      ::File.join(path)
    end

    def config_prefix_path
      join_path('/etc', 'consul')
    end

    def data_path
      join_path('/var/lib', 'consul')
    end

    def command(config_file, config_dir)
      "/usr/local/bin/consul agent -config-file=#{config_file} -config-dir=#{config_dir}"
    end

    # 1 is command not found
    def correct_version?(executable, version)
      shell_out!(%{"#{executable}" version}, returns: [0, 1]).stdout.match version
    end

    def binary_checksum(item)
      node['consul']['checksums'].fetch(binary_filename(item))
    end

    def binary_filename(item)
      case item
      when 'binary'
        arch = arch_64? ? 'amd64' : '386'
        ['consul', version, node['os'], arch].join('_')
      when 'web_ui'
        ['consul', version, 'web_ui'].join('_')
      end
    end

  end
end

Chef::Node.send(:include, ConsulCookbook::Helpers)
