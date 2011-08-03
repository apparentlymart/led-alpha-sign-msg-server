
use strict;
use warnings;
use LWP::UserAgent;
use Date::Parse;

my $ua = LWP::UserAgent->new();

$ua->post("http://127.0.0.1:8081/", { active => 1, message => "CHEESE FAIL" });

