# webpack_stats

A webpack stats loader for integrating rails with wepack.

## Install

```ruby
# Gemfile
gem 'webpack_stats'
```

## Usage

It's dead easy to use, there is no new API since it just overwrite `compute_asset_path` in `ActionView`. You can use every Rails assets API as usual, like `image_tag`, `asset_path`, etc. It will compute asset name correctly due to your webpack stats file.

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

## Integrate with Sprockets

Though Sprockets is dated, sometimes you could install gems that built on Sprockets like [administrate](https://github.com/thoughtbot/administrate).

To deal with the conflict, you have to take care of the ordering in `Gemfile`, for example:

```ruby
# Gemfile
gem 'sprockets-rails'
gem 'webpack_stats'

# effect
ActionView::Base.ancestors.first(4)
# => [ActionView::Base, WebpackStats::Helper, Sprockets::Rails::Helper, Sprockets::Rails::Utils]
```

Thus, `compute_asset_path` will fallback to Sprockets version if it can't find the given asset name in webpack stats file, and vice versa if you reverse the ordering.