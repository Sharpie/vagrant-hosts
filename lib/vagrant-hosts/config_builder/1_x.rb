require 'config_builder/model'

# Integration with ConfigBuilder 1.x and newer
#
# @since 2.7.0
module VagrantHosts
  module ConfigBuilder
    class Hosts < ::ConfigBuilder::Model::Provisioner::Base

      # @!attribute [rw] hosts
      def_model_attribute :hosts
      # @!attribute [rw] autoconfigure
      def_model_attribute :autoconfigure
      # @!attribute [rw] add_localhost_hostnames
      def_model_attribute :add_localhost_hostnames
      # @!attribute [rw] sync_hosts
      def_model_attribute :sync_hosts
      # @!attribute [rw] exports
      def_model_attribute :exports
      # @!attribute [rw] exports
      def_model_attribute :imports

      # @private
      def configure_hosts(config, val)
        val.each do |(address, aliases)|
          config.add_host(address, aliases)
        end
      end

      ::ConfigBuilder::Model::Provisioner.register('hosts', self)
    end

    class DnsUpdate < ::ConfigBuilder::Model::Provisioner::Base

      # @!attribute [rw] nameservers
      def_model_attribute :nameservers
      # @!attribute [rw] key
      def_model_attribute :tsig_key
      # @!attribute [rw] purge_on_destroy
      def_model_attribute :purge_on_destroy
      # @!attribute [rw] sync_hosts
      def_model_attribute :records

      ::ConfigBuilder::Model::Provisioner.register('dns_update', self)
    end
  end
end
