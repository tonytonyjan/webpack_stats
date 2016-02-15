# frozen-string-literal: true
require 'json'

module WebpackStats
  REGEXP = /(.+?)(?:-([0-9a-f]{20,}))?\.(\w+)/

  @reload = true
  @stats_path = 'stats.json'

  class << self
    attr_accessor :reload, :stats_path, :splitter

    def configure
      yield self
    end

    def assets
      load! if @reload || !@assets
      @assets
    end

    def stats
      load! if @reload || !@stats
      @stats
    end

    def load!
      if File.exists?(@stats_path)
        @stats = JSON.parse(File.read(@stats_path))
        @assets = {}
        @stats['assets'].each do |asset|
          key, value = split_asset_name(@stats, asset['name'])
          @assets[key] = value
        end
      else
        @stats = {}
        @assets = {}
      end
    end

    def split_asset_name stats, asset_name
      if @splitter.respond_to? :call
        @splitter.call stats['publicPath'], asset_name
      else
        full_name, name, hash, ext = REGEXP.match(asset_name).to_a
        ["#{name}.#{ext}", File.join(stats['publicPath'], full_name)]
      end
    end

  end

  module Helper
    def compute_asset_path source, options = {}
      WebpackStats.assets[source] || super
    end
  end
end

begin
  require 'active_support'
  ActiveSupport.on_load(:action_view) do
    include WebpackStats::Helper
  end

  ActiveSupport.on_load(:after_initialize) do
    WebpackStats.configure do |config|
      config.reload = !Rails.env.production?
      config.stats_path = Rails.root.join('stats.json')
    end
  end
rescue LoadError
end