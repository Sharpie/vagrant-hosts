require 'vagrant'
require 'vagrant-hosts/addresses'
require 'dnsruby'

module VagrantHosts
  module Provisioner
    class DnsUpdate < Vagrant.plugin('2', :provisioner)
      include VagrantHosts::Addresses

      def provision
        return if @config.records.empty?

        # Resolve nameservers to IP addresses using the system implementation
        # of getaddrinfo as Dnsruby will attempt to use it's own resolver,
        # which doesn't understand things such as /etc/resolver/ on OS X.
        nameservers = @config.nameservers.map {|s| resolve_ip(s).to_s}

        resolver = Dnsruby::Resolver.new({:nameservers => nameservers})

        @config.records.each do |domain, records|
          update = Dnsruby::Update.new(domain)
          # TODO: Consider whether this is the best approach. May be better to
          # just start off generating A and AAAA records from host names?
          records.each do |record|
            r = record.dup
            case r[1]
            when 'A', 'AAAA'
              r [0] = resolve_aliases(Array(r[0]), @machine).first
              r [3] = resolve_ip(resolve_addresses(r[3], @machine).first).to_s
            else
              raise ArgumentError, "Records of type #{r[1]} aren't handled yet."
            end
            update.add(*r)
          end

          unless @config.tsig_key.nil?
            update.set_tsig(@config.tsig_key)
          end

          @machine.ui.info "Sending update request to #{@config.nameservers.zip(nameservers)}:"
          @machine.ui.info update.to_s

          response = resolver.send_message(update)

          @machine.ui.info "Received response:"
          @machine.ui.info response.to_s
        end
      end

      def cleanup
        return unless @config.purge_on_destroy
        return if @config.records.empty?

        nameservers = @config.nameservers.map {|s| resolve_ip(s).to_s}

        resolver = Dnsruby::Resolver.new({:nameservers => nameservers})

        @config.records.each do |domain, records|
          update = Dnsruby::Update.new(domain)

          # TODO: Consider whether this is the best approach. May be better to
          # just start off generating A and AAAA records from host names?
          records.each do |record|
            r = record.dup
            case r[1]
            when 'A', 'AAAA'
              r [0] = resolve_aliases(Array(r[0]), @machine).first
              r [3] = resolve_ip(resolve_addresses(r[3], @machine).first).to_s
            else
              raise ArgumentError, "Records of type #{r[1]} aren't handled yet."
            end

            # Delete updates don't include r[2], the TTL value.
            update.delete(r[0], r[1], r[3])
          end

          unless @config.tsig_key.nil?
            update.set_tsig(@config.tsig_key)
          end

          @machine.ui.info "Sending update request to #{@config.nameservers.zip(nameservers)}:"
          @machine.ui.info update.to_s

          response = resolver.send_message(update)

          @machine.ui.info "\nReceived response:"
          @machine.ui.info response.to_s
        end
      end

    end
  end
end
