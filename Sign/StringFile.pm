package Sign::StringFile;

use strict;
use warnings;
use Carp qw(croak);

sub new {
    my ($class, $length, @initial_text) = @_;

    my $initial_text = join('', @initial_text);

    my $self = bless {}, $class;

    $self->{length} = $length or croak "Must supply a length";
    $self->{initial_text} = $initial_text;

    return $self;
}

sub initial_text {
    return $_[0]->{initial_text};
}

sub as_memory_config_block {
    my ($self) = @_;

    my $length = $self->{length};

    return join('', 'B', 'L', sprintf("%04X", $length), '0000');
}

1;
