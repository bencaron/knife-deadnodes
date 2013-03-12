require 'chef/knife'

module BenPlugins
  class NodeDead < Chef::Knife

    banner "knife node dead"

    option :tryssh, 
      :short => '-s',
      :long => '--ssh',
      :boolean => false,
      :description => "Also try to ssh to the host"


    deps do
      require 'chef/node'
      require 'chef/knife/search'
      require 'chef/search/query'



      require 'chef/knife/status'
      require 'highline'
      require 'dnsruby'
      include Dnsruby
    end

    def h
      @highline ||= HighLine.new
    end

    def r
      @resolver ||= Dnsruby::Resolver.new
    end

    def dns_exist?(n)
      begin
        Dnsruby::DNS.open do |dns|
          dns.getresource(n, "A")
        end
        #r.getaddresses(n)
        true
      rescue Dnsruby::NXDomain
        false
      rescue
        false
      end
    end

    def run
      
      hours = 24
      ui.msg "Looking for nodes with more than #{hours} hours without talking to our chef server"
      # cargo cult from https://github.com/lnxchk/Ohno/blob/master/lib/chef/knife/ohno.rb
      # not so cargo: this allow for the knife status output to not be shown to the user...
      stdout_orig = $stdout 
      $stdout = File.open('/dev/null', 'w')
      knife_status = Chef::Knife::Status.new
      hitlist = knife_status.run
      $stdout.close
      $stdout = stdout_orig

      ui.msg "Found #{hitlist.length} nodes, testing them..."
      hitlist.each do |node|
        hour, minutes, seconds = Chef::Knife::Status.new.time_difference_in_hms(node["ohai_time"])
        if hour >= hours
          ui.msg("#{node.name} \t\n\thas not checked in since " + ui.color("#{hour} hours!", :red) )
          if node[:fqdn] and dns_exist? node[:fqdn]
            result = `ping -q -c 1 #{node[:ipaddress]}`
            if ($?.exitstatus != 0) 
              ui.msg("\t\tand #{node[:ipaddress]} don't respond to ping. " + ui.color("Dead?", :yellow) )
              if config[:tryssh]
                tst = `ssh #{node[:fqdn]} "hostname"`
                if ($?.exitstatus != 0) 
                  ui.msg( "\t\tand #{node[:ipaddress]} don't allow me to ssh. " + ui.color("Dead?", :yellow))
                end
              end
            else
              ui.msg( "\tbut #{node[:ipaddress]} respond to ping. " + ui.color("Probably not dead.", :green))
            end
          else
            ui.msg("\tand #{node[:fqdn]} do not resolve. " + ui.color("Dead!", :red))
          end
        end
      end 

    end
  end
end
