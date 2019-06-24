# Setup Nix
set -l nix_profile_path ~/.nix-profile/etc/profile.d/nix.sh
if test -e $nix_profile_path
  # Source the nix setup script
  # We're going to run the regular Nix profile under bash and then print out a few variables
  for line in (env -u BASH_ENV bash -c '. "$0"; for name in PATH "${!NIX_@}"; do printf "%s=%s\0" "$name" "${!name}"; done' $nix_profile_path | string split0)
    set -xg (string split -m 1 = $line)
  end

  # Insert Nix's fish share directories into fish's special variables
  set -l nix_share ~/.nix-profile/share/fish
  set -l nix_vendor_functions $nix_share/vendor_functions.d
  if set -l idx (contains --index -- $__fish_data_dir/functions $fish_function_path)
    # Fish has no way to simply insert into the middle of an array
    set -l new_path $fish_function_path[1..$idx]
    set new_path[$idx] $nix_vendor_functions
    set fish_function_path $new_path $fish_function_path[$idx..-1]
  else
    set -a fish_function_path $nix_vendor_functions
  end

  set -l nix_vendor_comp $nix_share/vendor_completions.d
  if set -l idx (contains --index -- $__fish_data_dir/completions $fish_complete_path)
    set -l new_path $fish_complete_path[1..$idx]
    set new_path[$idx] $nix_vendor_comp
    set fish_complete_path $new_path $fish_complete_path[$idx..-1]
  else
    set -a fish_complete_path $nix_vendor_comp
  end

  set -l nix_conf $nix_share/vendor_conf.d
  # In order to simulate being the extra conf, we need to make sure it hasn't been "overridden" yet
  # we're not going to actually check for our actual extra confdir. And we're technically sourcing
  # these files out of order, and can't stop anything in the real extra confdir from sourcing.
  # This is cribbed from $__fish_data_dir/config.fish
  set -l sourcelist
  set -l configdir ~/.config
  if set -q XDG_CONFIG_HOME
    set configdir $XDG_CONFIG_HOME
  end
  for file in $configdir/fish/conf.d/*.fish $__fish_sysconf_dir/conf.d/*.fish
    set -l basename (string replace -r '^.*/' '' -- $file)
    contains -- $basename $sourcelist
    and continue
    set -a sourcelist $basename
    # Don't source, these files have already been sourced by Fish's global setup
  end
  for file in $nix_conf/*.fish
    set -l basename (string replace -r '^.*/' '' -- $file)
    contains -- $basename $sourcelist
    and continue
    # Source the file
    [ -f $file -a -r $file ]
    and source $file
  end
end
