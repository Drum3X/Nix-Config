# Short names for the commands this repo is worked with. `just` lists them.

host := "nitro"
toplevel := ".#nixosConfigurations." + host + ".config.system.build.toplevel"

[private]
default:
    @just --list

# Build, show the package diff, activate and make it the boot default
switch:
    nh os switch .

# Activate without a boot entry; a reboot goes back to the previous generation
test:
    nh os test .

# Build and show the package diff, change nothing
diff:
    nh os build .

# Evaluate the system without building it (enough for package additions)
eval:
    nix eval --raw {{ toplevel }}.drvPath

# Build the whole system without activating it (module and service changes)
build:
    nix build --no-link --print-out-paths {{ toplevel }}

# Update all inputs, or only the ones given (just up kioku), then show the diff
up *inputs:
    nix flake update {{ inputs }}
    nh os build .

# What CI runs: evaluate the flake and check formatting
check:
    nix flake check --no-build
    nix fmt -- --ci

# Format every Nix file
fmt:
    nix fmt

# Garbage-collect now, keeping the last 5 generations and the last 7 days
clean:
    nh clean all --keep 5 --keep-since 7d

# Open the system configuration in nix repl
repl:
    nh os repl .
