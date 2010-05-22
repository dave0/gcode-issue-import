#!/usr/bin/perl
use strict;
use warnings;
use Net::Google::Code;
use Net::GitHub;
use LWP::UserAgent;
use Text::CSV_XS;

my($gc_proj, $gh_proj) = @ARGV;

my %github;
@github{qw( owner repo )} = split '/', $gh_proj;

chomp($github{login} = `git config github.user`);
chomp($github{token} = `git config github.token`);

my $code = Net::Google::Code->new(project => $gc_proj);
my $github = Net::GitHub->new(%github);

for my $id (get_issues($code)) {
    my $issue = $code->issue;
    $issue->load($id);
    my $gh_issue = $github->issue->open($issue->summary, $issue->description);
    warn "$id -> " . $gh_issue->{number};
}

sub get_issues {
    my $ua = LWP::UserAgent->new;
    my $content = $ua->get("http://code.google.com/p/$gc_proj/issues/csv")->content;
    open my $io, '<', \$content;
    my $parser  = Text::CSV_XS->new({ binary => 1 });
    $parser->column_names($parser->getline($io));

    my @issues;
    while (my $row = $parser->getline_hr($io)) {
        last unless $row->{ID};
        push @issues, $row->{ID};
    }

    return @issues;
}

