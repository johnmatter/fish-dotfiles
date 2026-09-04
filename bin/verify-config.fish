#!/usr/bin/env fish
#
# verify-config — assert this machine's fish config starts clean.
#
# Run on every host that tracks this repo; the config is shared, so a change
# that is fine on one machine can break startup on another. Checks:
#
#   1. a login+interactive shell emits nothing on stderr
#   2. PATH has no duplicate entries
#   3. conf.d/ holds no host-specific files
#   4. every plugin declared in fish_plugins is actually installed
#
# 2 and 3 are regressions, not hypotheticals: host files used to live in
# conf.d/, which fish auto-sources, so every host loaded every other host's
# file, and its own twice — which duplicated PATH entries.
#
# Exits 0 if all checks pass, 1 otherwise.

set -g failures 0
function check_failed -a msg
    echo "FAIL  $msg" >&2
    set -g failures (math $failures + 1)
end

set -l fish_bin (status fish-path)
set -l conf_d (dirname (status filename))/../conf.d

# 1. Startup must be silent. -i is what matters: it runs the interactive
#    startup path (conf.d, prompt, key bindings), which is where startup
#    errors actually surface.
set -l stderr_out ($fish_bin -l -i -c exit 2>&1 >/dev/null | string collect)
test -n "$stderr_out"; and check_failed "login+interactive startup wrote to stderr:"\n"$stderr_out"
test $failures -eq 0; and echo "ok    startup is silent"

# 2. Duplicate PATH entries mean something is being sourced twice.
set -l dupes ($fish_bin -l -c 'for p in $PATH; echo $p; end' | sort | uniq -d)
if test (count $dupes) -gt 0
    check_failed "PATH contains duplicate entries: $dupes"
else
    echo "ok    PATH has no duplicates"
end

# 3. Host files must live in hosts/, never conf.d/ — fish auto-sources conf.d.
set -l stray (ls $conf_d 2>/dev/null | string match 'hostname-*')
if test (count $stray) -gt 0
    check_failed "host-specific files still in conf.d/ (fish auto-sources these on every machine): $stray"
else
    echo "ok    conf.d/ has no host-specific files"
end

# 4. fish_plugins is the tracked, declarative plugin set; fisher's registry
#    lives in the untracked fish_variables and is derived from it. If a machine
#    has the manifest but not the registry (fresh clone, reset universals), the
#    plugins still work — their files are tracked — but fisher can't manage
#    them until `fisher update` reconciles the two.
set -l manifest (dirname (status filename))/../fish_plugins
if test -f $manifest
    set -l declared (string trim <$manifest | string match -er '\\S')
    set -l installed (fisher list 2>/dev/null)
    set -l missing
    for plugin in $declared
        contains -- $plugin $installed; or set -a missing $plugin
    end
    if test (count $missing) -gt 0
        check_failed "declared in fish_plugins but not registered with fisher (run `fisher update`): $missing"
    else
        echo "ok    all "(count $declared)" declared plugins are installed"
    end
end

if test $failures -gt 0
    echo "" >&2; echo "$failures check(s) failed" >&2
    exit 1
end
echo ""; echo "all checks passed on "(hostname)
