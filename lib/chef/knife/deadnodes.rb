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
      #require 'chef/node'
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
        r.getaddress(n)
        true
      rescue Dnsruby::NXDomain
        false
      end
    end

    def run
      
      hours = 24

      # cargo cult from https://github.com/lnxchk/Ohno/blob/master/lib/chef/knife/ohno.rb
#      stdout_orig = $stdout 
#      $stdout = File.open('/dev/null', 'w')
      knife_status = Chef::Knife::Status.new
      hitlist = knife_status.run
#      $stdout.close
#      $stdout = stdout_orig


      hitlist.each do |node|
        hour, minutes, seconds = Chef::Knife::Status.new.time_difference_in_hms(node["ohai_time"])
        if hour >= hours
          if dns_exists? node[:fqdn]
            result = `ping -q -c 1 #{node[:ipaddress]}`
            if ($?.exitstatus != 0) 
              ui.msg("#{node.name} \t has not checked in since " + ui.color("#{x} hours", :red) + " and #{node[:ipaddress]} don't respond to ping. Dead?")
              if config[:tryssh]
                tst = `ssh #{node[:fqdn]} "hostname"`
                if ($?.exitstatus != 0) 
                  ui.msg("#{node.name} \t has not checked in since " + ui.color("#{x} hours", :red) + " #{node[:ipaddress]} don't respond to ping, don't allow me to ssh. Dead?")
                end
                ui.msg "we should also try to ssh to the host!"
              end
            else
              ui.msg("#{node.name} \t has not checked in since " + ui.color("#{x} hours", :red) + "; #{node[:ipaddress]} respond to ping. Probably not dead.")
            end
          else
            ui.msg("#{node.name} \t has not checked in since " + ui.color("#{x} hours", :red) + " and #{node[:fqdn]} do not resolve. Dead!")
          end
        end
      end 

    end
  end
end
