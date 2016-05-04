#
# Cookbook: consul
# License: Apache 2.0
#
# Copyright 2014-2016, Bloomberg Finance L.P.
#
require 'poise'
require_relative './helpers'

module ConsulCookbook
  module Provider
    # A `consul_installation` provider which manages Consul binary
    # installation from remote source URL.
    # @action create
    # @action remove
    # @provides consul_installation
    # @example
    #   consul_installation '0.5.0'
    # @since 2.0
    class ConsulInstallationBinary < Chef::Provider
      include Poise(inversion: :consul_installation)
      include ::ConsulCookbook::Helpers
      provides(:binary)
      inversion_attribute('consul')

      # @api private
      def self.provides_auto?(_node, _resource)
        true
      end

      # Set the default inversion options.
      # @return [Hash]
      # @api private
      def self.default_inversion_options(node, resource)
        archive_basename = binary_basename(node, resource)
        extract_to = '/opt/consul'
        super.merge(
          version: resource.version,
          archive_url: default_archive_url % { version: resource.version, basename: archive_basename },
          archive_basename: archive_basename,
          archive_checksum: binary_checksum(node, resource),
          extract_to: extract_to
        )
      end

      def action_create
        archive_url = options[:archive_url] % {
          version: options[:version],
          basename: options[:archive_basename]
        }

        notifying_block do
          directory join_path(options[:extract_to], new_resource.version) do
            recursive true
          end

          zipfile options[:archive_basename] do
            path join_path(options[:extract_to], new_resource.version)
            source archive_url
            checksum options[:archive_checksum]
            not_if { ::File.exist?(consul_program) }
          end
        end
      end

      def action_remove
        notifying_block do
          directory join_path(options[:extract_to], new_resource.version) do
            recursive true
            action :delete
          end
        end
      end

      def consul_program
        @program ||= join_path(options[:extract_to], new_resource.version, 'consul')
      end

      def self.default_archive_url
        "https://releases.hashicorp.com/consul/%{version}/%{basename}" # rubocop:disable Style/StringLiterals
      end

      def self.binary_basename(node, resource)
        case node['kernel']['machine']
        when 'x86_64', 'amd64' then ['consul', resource.version, node['os'], 'amd64'].join('_')
        when /i\d86/ then ['consul', resource.version, node['os'], '386'].join('_')
        else ['consul', resource.version, node['os'], node['kernel']['machine']].join('_')
        end.concat('.zip')
      end

      def self.binary_checksum(node, resource)
        tag = node['kernel']['machine'] =~ /x86_64/ ? 'amd64' : node['kernel']['machine']
        case [node['os'], tag].join('-')
        when 'darwin-amd64'
          case resource.version
          when '0.5.0' then '24d9758c873e9124e0ce266f118078f87ba8d8363ab16c2e59a3cd197b77e964'
          when '0.5.1' then '161f2a8803e31550bd92a00e95a3a517aa949714c19d3124c46e56cfdc97b088'
          when '0.5.2' then '87be515d7dbab760a61a359626a734f738d46ece367f68422b7dec9197d9eeea'
          when '0.6.0' then '29ddff01368458048731afa586cec5426c8033a914b43fc83d6442e0a522c114'
          when '0.6.1' then '358654900772b3477497f4a5b5a841f2763dc3062bf29212606a97f5a7a675f3'
          when '0.6.2' then '3089f77fcdb922894456ea6d0bc78a2fb60984d1d3687fa9d8f604b266c83446'
          when '0.6.3' then '6dff4ffc61d66aacd627a176737b8725624718a9e68cc81460a3df9b241c7932'
          when '0.6.4' then '75422bbd26107cfc5dfa7bbb65c1d8540a5193796b5c6b272d8d70b094b26488  '
          end
        when 'linux-amd64'
          case resource.version
          when '0.5.0' then '161f2a8803e31550bd92a00e95a3a517aa949714c19d3124c46e56cfdc97b088'
          when '0.5.1' then '967ad75865b950698833eaf26415ba48d8a22befb5d4e8c77630ad70f251b100'
          when '0.5.2' then '171cf4074bfca3b1e46112105738985783f19c47f4408377241b868affa9d445'
          when '0.6.0' then '307fa26ae32cb8732aed2b3320ed8daf02c28b50d952cbaae8faf67c79f78847'
          when '0.6.1' then 'dbb3c348fdb7cdfc03e5617956b243c594a399733afee323e69ef664cdadb1ac'
          when '0.6.2' then '7234eba9a6d1ce169ff8d7af91733e63d8fc82193d52d1b10979d8be5c959095'
          when '0.6.3' then 'b0532c61fec4a4f6d130c893fd8954ec007a6ad93effbe283a39224ed237e250'
          when '0.6.4' then 'abdf0e1856292468e2c9971420d73b805e93888e006c76324ae39416edcf0627'
          end
        end
      end
    end
  end
end
