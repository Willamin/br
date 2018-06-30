# br

_Bulk Renaming tool_

## Usage

1. `$ br GLOB [GLOB ...]`
2. Your editor will be opened (or `vim` if `EDITOR` is unset).
3. Edit the list of file names as you see fit.
4. Save and close your editor.
5. Your files will be renamed!

## Installation

| Step | Description | Sample Bash |
|---|----|----|
| 1 | Clone the repo | `$ git clone https://github.com/willamin/br` |
| 2 | Change your directory to it | `$ cd br` |
| 3 | Build in release mode, retrieving necessary dependencies | `$ shards build --release --production` |
| 5 | Copy the executable to somewhere in your `PATH` | eg. `$ cp bin/br ~/bin/br` |

TODO: Release prebuilt binaries

## Contributing

1. Fork it ( https://github.com/willamin/br/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [willamin](https://github.com/willamin) Will Lewis - creator, maintainer
