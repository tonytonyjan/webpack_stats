require 'minitest/autorun'
require 'webpack_stats'

class TestWebpackStats < Minitest::Test
  def setup
    WebpackStats.configure do |config|
      config.stats_path = File.expand_path('../stats.json', __FILE__)
    end
  end

  def test_assets
    WebpackStats.configure do |config|
      config.splitter = nil
    end
    assert_equal '/assets/MaterialIcons-Regular-81025269949a562d06d5e316f733b140.woff2', WebpackStats.assets['MaterialIcons-Regular.woff2']
    assert_equal '/assets/tony-8c12cdc3c76d0634845109ebe500aa6b.png', WebpackStats.assets['tony.png']
    assert_equal nil, WebpackStats.assets['not found']
  end

  def test_configure_splitter
    WebpackStats.configure do |config|
      config.splitter = ->(stats, asset_name){ ['foo', 'bar'] }
    end
    assert_equal 'bar', WebpackStats.assets['foo']
  end
end