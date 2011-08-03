package Sign::MessageUtil;

use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(mode charset lines fancylines string flash_text show_time show_day_of_week show_date);

our %MODE_CODES = (
    ROTATE     => 'a',
    HOLD       => 'b',
    FLASH      => 'c',
    # 'd' is reserved
    ROLL_UP    => 'e',
    ROLL_DOWN  => 'f',
    ROLL_LEFT  => 'g',
    ROLL_RIGHT => 'h',
    WIPE_UP    => 'i',
    WIPE_DOWN  => 'j',
    WIPE_LEFT  => 'k',
    WIPE_RIGHT => 'l',
    SCROLL     => 'm',
    AUTOMODE   => 'o',
    ROLL_IN    => 'p',
    ROLL_OUT   => 'q',
    WIPE_IN    => 'r',
    WIPE_OUT   => 's',
    ROTATE_COMPRESSED => 't',
    EXPLODE    => 'u',
    CLOCK      => 'v',
    TWINKLE    => 'n0',
    SPARKLE    => 'n1',
    SNOW       => 'n2',
    INTERLOCK  => 'n3',
    SWITCH     => 'n4',
    SLIDE      => 'n5',
    SPRAY      => 'n6',
    STARBURST  => 'n7',
    WELCOME    => 'n8',
    SLOT_MACHINE => 'n9',
    NEWS_FLASH => 'nA',
    TRUMPET    => 'nB',
    CYCLE_COLORS => 'nC',
    THANK_YOU  => 'nS',
    NO_SMOKING => 'nU',
    DONT_DRINK_AND_DRIVE => 'nV',
    RUNNING_ANIMAL => 'nW',
    FIREWORKS  => 'nX',
    TURBO_CAR  => 'nY',
    CHERRY_BOMB => 'nZ',
);

our %DISPLAY_POSITIONS = (
    MIDDLE   => ' ',
    TOP      => '"',
    BOTTOM   => '&',
    FILL     => '0',
    LEFT     => '1',
    RIGHT    => '2',
);

sub mode {
    my ($mode, $display_position) = @_;

    $display_position ||= 'FILL';

    my $mode_code = $MODE_CODES{$mode};
    my $display_position_code = $DISPLAY_POSITIONS{$display_position};

    Carp::croak("$mode is not a supported mode code") unless defined($mode_code);
    Carp::croak("$display_position is not a supported display position") unless defined($display_position_code);

    # FIXME: Should die if one of the keywords is not recognized, rather than emitting
    # a malformed escape sequence as this will do as written.
    return join('', "\c[", $display_position_code, $mode_code);
}

sub charset {

}

sub lines {
    my @strings = @_;

    return join("\cM", @strings);
}

sub fancylines {
    my ($mode, @strings) = @_;

    return join(mode($mode), @strings);
}

sub string {
    my ($label) = @_;

    return join('', "\cP", $label);
}

sub flash_text {
    my ($text) = @_;

    return join('', "\cG1", $text, "\cG0");
}

sub show_time {
    return "\cS";
}

sub show_date {
    return "\cK8";
}

sub show_day_of_week {
    return "\cK9";
}

1;
