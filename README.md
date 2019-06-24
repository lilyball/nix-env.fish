# nix-env.fish

Sets up the Nix environment for a non-Nix-installed [Fish shell](http://fishshell.com).

Beyond just setting up `$PATH` and the various `$NIX_*` environment variables, this also sets up `$fish_function_path` and `$fish_complete_path` to include any Nix-installed Fish functions/completions, and sources any Nix-installed Fish `conf.d` 

## Install

Any Fish package manager should be able to install this.

### [Fisher](https://github.com/jorgebucaran/fisher)

```fish
fisher add lilyball/nix-env.fish
```
