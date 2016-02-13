# webpack_stats

A webpack stats loader for intergrating rails with wepack.

## Install

```ruby
# Gemfile
gem 'webpack_stats'
```

## Usage

It's dead easy to use, there is no new API since it just overwrite `#compute_asset_path` in `ActionView`. You can use every Rails assets API as usual, like `image_tag`, `asset_path`, etc. It will compute asset name correctlly due to your webpack stats file.

To generate the stats file, simply execute `webpack --json`, or add the code below to `webpack.config.js`:

```js
plugins = [
  function() {
    this.plugin('done', function(stats) {
      require('fs').writeFileSync(__dirname + '/stats.json', JSON.stringify(stats.toJson()))
    })
  }
]
```

Sample `webpack.config.js` is [Here](https://github.com/tonytonyjan/rails_on_webpack/blob/master/webpack.config.js).

## Configuration

The default configuration below:

```ruby
# config/initializers/webpack_stats.rb
WebpackStats.configure do |config|
  # Autoreload stats file for each request.
  config.autoload = !Rails.env.production?

  config.stats_path = Rails.root.join('stats.json')

  config.splitter = ->(stats, asset_name){
    # should return a pari of string. The first is the asset name to be computed
    # (ex. "app.js"), the second is the computed asset name (ex. "app-hash.js").
    full_name, name, hash, ext = WebpackStats::REGEXP.match(asset_name).to_a
    ["#{name}.#{ext}", File.join(stats['publicPath'], full_name)]
  }
end
```