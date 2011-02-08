require 'net/https'

module Jquery
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "This generator downloads and installs jQuery, jQuery-ujs HEAD, and (optionally) the newest jQuery UI"
      class_option :ui, :type => :boolean, :default => false, :desc => "Include jQueryUI"
      class_option :version, :type => :string, :default => "1.5", :desc => "Which version of jQuery to fetch"
      class_option :jqgrid, :type => :boolean, :default => false, :desc => "Include jqGrid"
      @@default_version = "1.5"

      def remove_prototype
        %w(controls.js dragdrop.js effects.js prototype.js).each do |js|
          remove_file "public/javascripts/#{js}"
        end
      end

      def download_jquery
        say_status("fetching", "jQuery (#{options.version})", :green)
        get_jquery(options.version)
      rescue OpenURI::HTTPError
        say_status("warning", "could not find jQuery (#{options.version})", :yellow)
        say_status("fetching", "jQuery (#{@@default_version})", :green)
        get_jquery(@@default_version)
      end

      def download_jquery_ui
        if options.ui?
          say_status("fetching", "jQuery UI (latest 1.x release)", :green)
          get "http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.js",     "public/javascripts/jquery-ui.js"
          get "http://ajax.googleapis.com/ajax/libs/jqueryui/1/jquery-ui.min.js", "public/javascripts/jquery-ui.min.js"
        end
      end

      def download_jquery_jqgrid
        if options.jqgrid?
          say_status("fetching", "jQuery jqGrid", :green)
          get "https://github.com/tonytomov/jqGrid/raw/master/js/grid.base.js",     "public/javascripts/jquery.grid.base.js"
        end
      end
      
      def download_ujs_driver
        say_status("fetching", "jQuery UJS adapter (github HEAD)", :green)
        url = URI.parse('https://github.com/rails/jquery-ujs/raw/master/src/rails.js')
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.ca_file = File.join(File.dirname(__FILE__), "cacert.pem")
        resp = http.request_get(url.to_s, 'public/javascripts/rails.js')
        open("public/javascripts/rails.js", "wb") {|file| 
          file.write(resp.body)
        }
      end

    private

      def get_jquery(version)
        get "http://ajax.googleapis.com/ajax/libs/jquery/#{version}/jquery.js",     "public/javascripts/jquery.js"
        get "http://ajax.googleapis.com/ajax/libs/jquery/#{version}/jquery.min.js", "public/javascripts/jquery.min.js"
      end

    end
  end
end
