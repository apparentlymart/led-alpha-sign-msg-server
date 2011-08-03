#!/usr/bin/perl

use strict;
use warnings;
use Fcntl;
use Data::Dumper;
use Sign;
use Sign::TextFile;
use Sign::StringFile;
use Sign::MessageUtil qw(mode fancylines lines string flash_text show_time show_day_of_week show_date);
use XML::XPath;
use XML::XPath::Node;
use AnyEvent;
use AnyEvent::HTTPD;

our %alert_status = ();

my $serial_device = "/dev/ttyS0";
my $http_port = 8081;

sysopen(my $fh, $serial_device, O_RDWR) || die "Can't open serial port: $!";

my $sign = Sign->new($fh);
bootstrap_sign();

run_service($http_port);

close($fh);

sub bootstrap_sign {

    $sign->sync_time();

    my %files = ();

    $sign->configure_files(
        'A' => Sign::TextFile->new(mode("HOLD")),
    );

    $sign->clear_priority_text_file_text();

}

sub update_priority_message {

    my @alerts_to_show = sort keys %alert_status;

    if (@alerts_to_show) {
        $sign->set_priority_text_file_text(mode("HOLD"), lines(map { flash_text($_) } @alerts_to_show));
    }
    else {
        $sign->clear_priority_text_file_text();
    }

}

sub run_service {
    my ($http_port) = @_;

    my $httpd = AnyEvent::HTTPD->new(port => $http_port);

    $httpd->reg_cb(
        '' => sub {
            my ($httpd, $req) = @_;

            unless ($req->method eq 'POST') {
                $req->respond([ 405, "Method not allowed", { 'Content-Type' => 'text/plain' }, 'Please POST to me' ]);
                return;
            }

            my $result = handle_request($req);

            if ($result) {
                $req->respond([ 200, "OK", { 'Content-Type' => 'text/plain' }, 'OK' ]);
            }
            else {
                $req->respond([ 500, "Not OK", { 'Content-Type' => 'text/plain' }, 'Not OK' ]);
            }
        },
    );

    $httpd->run;
}

sub handle_request {
    my ($req) = @_;

    my $url = $req->url;

    unless ($url->path eq '/') {
        return 0;
    }

    my %params = $req->vars;
    my $new_active = $params{active};
    my $message = $params{message};

    if ($new_active) {
        $alert_status{$message} = 1;
    }
    else {
        delete $alert_status{$message};
    }

    update_priority_message();

    return 1;
}

