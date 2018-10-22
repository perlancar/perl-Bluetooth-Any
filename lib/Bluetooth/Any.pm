package Bluetooth::Any;

# DATE
# VERSION

use 5.010001;
use strict;
use warnings;
use Log::ger;

use Exporter::Rinci qw(import);
use File::Which qw(which);
use IPC::System::Options 'system', 'readpipe', -log=>1;

our %SPEC;

$SPEC{':package'} = {
    v => 1.1,
    summary => 'Common interface to bluetooth functions',
    description => <<'_',

This module provides common functions related to bluetooth.

_
};

$SPEC{'turn_on_bluetooth'} = {
    v => 1.1,
    summary => 'Turn on Bluetooth',
    description => <<'_',

Will try:
- rfkill

_
};
sub turn_on_bluetooth {
    my %args = @_;

  RFKILL:
    {
        unless (which("rfkill")) {
            log_trace "Cannot find rfkill, skipping using rfkill";
            last;
        }
        log_trace "Using rfkill to turn bluetooth on";
        system "rfkill", "unblock", "bluetooth";
        unless ($?) {
            return [200, "OK", {'func.method'=>'rfkill'}];
        }
    }
    [500, "Failed, no methods succeeded"];
}

$SPEC{'bluetooth_is_on'} = {
    v => 1.1,
    summary => 'Return true when bluetooth is on, or 0 otherwise',
    description => <<'_',

Will try:
- rfkill

_
};
sub bluetooth_is_on {
    my %args = @_;

  RFKILL:
    {
        unless (which("rfkill")) {
            log_trace "Cannot find rfkill, skipping using rfkill";
            last;
        }
        log_trace "Using rfkill to check bluetooth status";
        my $out;
        system {capture_stdout=>\$out}, "rfkill", "block", "bluetooth";
        last if $?;
        my $in_bt;
        for (split /^/m, $out) {
            if (/^\d/) {
                if (/bluetooth/i) {
                    $in_bt = 1;
                } else {
                    $in_bt = 0;
                }
                next;
            } else {
                if (/blocked:\s*yes/i) {
                    return [200, "OK", 0, {'func.method'=>'rfkill'}];
                }
            }
        }
        return [200, "OK", 1, {'func.method'=>'rfkill'}];
    }
    [500, "Failed, no methods succeeded"];
}

1;
# ABSTRACT:
