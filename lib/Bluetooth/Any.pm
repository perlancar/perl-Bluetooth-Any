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
            return [200, "OK", undef, {'func.method'=>'rfkill'}];
        }
    }
    [500, "Failed, no methods succeeded"];
}

$SPEC{'turn_off_bluetooth'} = {
    v => 1.1,
    summary => 'Turn off Bluetooth',
    description => <<'_',

Will try:
- rfkill

_
};
sub turn_off_bluetooth {
    my %args = @_;

  RFKILL:
    {
        unless (which("rfkill")) {
            log_trace "Cannot find rfkill, skipping using rfkill";
            last;
        }
        log_trace "Using rfkill to turn bluetooth off";
        system "rfkill", "block", "bluetooth";
        unless ($?) {
            return [200, "OK", undef, {'func.method'=>'rfkill'}];
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
        system {capture_stdout=>\$out}, "rfkill", "list", "bluetooth";
        last if $?;
        my $in_bt;
        my $unblocked;
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
                    return [200, "OK", 0, {'func.method'=>'rfkill', 'cmdline.result'=>'Bluetooth is OFF', 'cmdline.exit_code'=>1}];
                } elsif (/blocked:\s*no/i) {
                    $unblocked = 0;
                }
            }
        }

        if (defined $unblocked) {
            return [200, "OK", 1, {'func.method'=>'rfkill', 'cmdline.result'=>'Bluetooth is on', 'cmdline.exit_code'=>0}];
        } else {
            log_warn "Cannot detect 'blocked: no' from 'rfkill list' output, skipping using rfkill";
            last;
        }
    }
    [500, "Failed, no methods succeeded"];
}

1;
# ABSTRACT:
