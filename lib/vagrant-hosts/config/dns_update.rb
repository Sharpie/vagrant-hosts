require 'vagrant'

module VagrantHosts;end

module VagrantHosts::Config
  # Configuration for the dns_update provider
  #
  # @since 2.9.0
  class DnsUpdate < Vagrant.plugin('2', :config)

    # @!attribute [rw] nameservers
    #   @return [Array<String>] A list of nameservers to which DNS updates will
    #     be sent.
    attr_accessor :nameservers

    # @!attribute [rw] key
    #   @return [Hash{Symbol => String}, nil] An optional hash specifying
    #     the DNS key to be used when signing updates with TSIG.
    attr_accessor :tsig_key

    # @!attribute [rw] purge_on_destroy
    #   @return [TrueClass, FalseClass] When set to true, the `dns_update`
    #     provisioner will send `delete` updates to the nameservers to
    #     remove data specified in {#records} when a VM is detroyed.
    #     Defaults to `true`.
    attr_accessor :purge_on_destroy

    # @!attribute [rw] exports
    #   @return [Hash{String => Array<Array<String, Array<String>>>}]
    #     A hash containing named lists of `[address, [aliases]]` tuples
    #     that define DNS records for this VM.
    attr_accessor :records

    def initialize
      @nameservers = []
      @tsig_key = nil
      @purge_on_destroy = true
      @records = {}
    end

    def finalize!
      @nameservers = Array(@nameservers)
    end

    def validate(machine)
      errors = []

      {"Vagrant Hosts" => errors}
    end
  end
end
