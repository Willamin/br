# br

_Bulk Renaming tool_

## Usage

1. `$ br [OPTIONS] GLOB [GLOB ...]`
2. Your editor will be opened (or `vim` if `EDITOR` is unset).
3. Edit the list of file names as you see fit.
4. Save and close your editor.
5. Your files will be renamed!

Options:
- `--dry-run` runs `br` as normal, except renames don't occur. Instead, a description of the renamings is printed.
- `--verbose` runs `br` as normal, except it prints to STDERR as things happen.

## Installation

```shell
git clone https://github.com/willamin/br  # Clone the project
cd br                                     # Change your directory to it
shards build --release --production       # Build in release mode
cp bin/br ~/bin/br                        # Copy the binary to be in your PATH
```

TODO: Release prebuilt binaries

## Contributing

1. Fork it ( https://github.com/willamin/br/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [willamin](https://github.com/willamin) Will Lewis - creator, maintainer
