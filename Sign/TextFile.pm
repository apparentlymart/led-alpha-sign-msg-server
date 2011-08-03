package Sign::TextFile;

use strict;
use warnings;
use Carp qw(croak);

sub new {
    my ($class, @text) = @_;

    my $text = join('', @text);

    croak("You must supply some initial text") unless defined($text) && length($text) > 0;

    my $self = bless {}, $class;

    $self->{text} = $text;
    $self->{times} = "FF00";

    return $self;
}

sub text {
    return $_[0]->{text};
}

sub as_memory_config_block {
    my ($self) = @_;

    my $text = $self->{text};
    my $label = $self->{label};
    my $times_block = $self->{times};

    return join('', 'A', 'L', sprintf("%04X", length($text)), $times_block);
}

1;
