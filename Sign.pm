package Sign;

use strict;
use warnings;

use constant SYNC => "\x00" x 5;
use constant SOH => "\x01";
use constant STX => "\x02";
use constant ETX => "\x03";
use constant EOT => "\x04";

# This is both the type code of "all sign types" and
# the broadcast address of "all connected signs"
# concatenated together.
use constant ALL_SIGNS => '?00';

sub new {
    my ($class, $fh) = @_;

    my $self = bless {}, $class;
    $self->{fh} = $fh;
    return $self;
}

sub _send_packet {
    my ($sign, $body) = @_;

    my $payload = join('', STX, $body, ETX);
    my $checksum = unpack('%16C*', $payload);

    my $printable_body = $body;
    $printable_body =~ s/([\x00-\x1F])/"\e[1m^".chr(ord($1) + 64)."\e[0m"/eg;
    warn "Sending payload $printable_body";

    my $packet = join('', SYNC, SOH, ALL_SIGNS, $payload, sprintf("%04X", $checksum), EOT);

    syswrite($sign->{fh}, $packet) or warn "Failed to write to sign: $!";

}

sub configure_files {
    my ($sign, %files) = @_;

    my %messages = ();
    my %strings = ();

    my @chunks;
    foreach my $label (sort keys %files) {
        my $file = $files{$label};

        push @chunks, join('', $label, $file->as_memory_config_block);

        if ($file->isa('Sign::TextFile')) {
            $messages{$label} = $file->text;
        }
        elsif ($file->isa('Sign::StringFile')) {
            $strings{$label} = $file->initial_text;
        }
    }

    $sign->_send_packet(join('', 'E$', @chunks));

    foreach my $label (sort keys %messages) {
        my $text = $messages{$label};
        $sign->set_text_file_text($label => $text);
    }

    foreach my $label (sort keys %strings) {
        my $text = $strings{$label};
        $sign->set_string_file_text($label => $text);
    }
}

sub configure_text_file_run_sequence {
    my ($sign, @labels) = @_;

    $sign->_send_packet(join('', 'E', "\x2E", 'T', 'L', @labels));
}

sub set_text_file_text {
    my ($sign, $label, @text) = @_;

    $sign->_send_packet(join('', "A", $label, @text));
}

sub set_string_file_text {
    my ($sign, $label, @text) = @_;

    $sign->_send_packet(join('', "G", $label, @text));
}

sub set_priority_text_file_text {
    my ($sign, @text) = @_;

    $sign->set_text_file_text('0' => @text);
}

sub clear_priority_text_file_text {
    my ($sign) = @_;

    $sign->set_text_file_text('0' => '');
}

sub soft_reset {
    my ($sign) = @_;

    $sign->_send_packet("E,");
}

sub sync_time {
    my ($sign) = @_;

    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);

    $sign->_send_packet("E&".($wday+1));
    $sign->_send_packet(join('', "E;", sprintf("%02i", $mon+1), sprintf("%02i", $mday), sprintf("%02i", $year % 100)));
    $sign->_send_packet(join('', "E ", sprintf("%02i", $hour), sprintf("%02i", $min)));
}

1;
