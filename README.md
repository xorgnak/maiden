# Maiden
A simple republishing of a gem to calculate maidenhead gridsquares by gps coordinates.

## Installation

### bundle
```
bundle add maiden
```

### gem
```
gem install maiden
```

### build
```
gem build maiden.gemspec
```

## Usage
```
require 'maiden'
```

### to grid
```
gridsquare = GRID.to_grid(latitude, longitude)
```

### to gps
```
latitude, longitude = GRID.to_gps(gridsquare)
```

### gridsquares
```
GRID.keys
```

### gridsquare stack
```
GRID[gridsquare]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

