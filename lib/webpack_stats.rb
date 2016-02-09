# frozen-string-literal: true
require 'json'

module WebpackStats
  REGEXP = /(.+?)(?:-([0-9a-f]{20,}))?\.(\w+)/

  @reload = defined?(::Rails) && ::Rails.env.production? ? false : true
  @stats_path = defined?(::Rails) ? ::Rails.root.join('stats.json') : 'stats.json'

  class << self
    attr_accessor :reload, :stats_path, :splitter

    def configure
      yield self
    end

    def assets
      @reload ? load_assets : @assets ||= load_assets
    end

    def stats
      @reload ? load_stats : @stats ||= load_stats
    end

    def load_stats
      JSON.parse File.read @stats_path
    end

    def load_assets
      ret = {}
      _stats = stats
      _stats['assets'].each do |asset|
        key, value = split_asset_name(_stats, asset['name'])
        ret[key] = value
      end
      ret
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

  if defined? ::Rails
    module Helper
      def compute_asset_path source, options = {}
        WebpackStats.assets[source] || super
      end
    end
  end

end

if defined? ::ActiveSupport
  ActiveSupport.on_load(:action_view) do
    include WebpackStats::Helper
  end
end