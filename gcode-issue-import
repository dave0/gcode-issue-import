#!/usr/bin/perl
use strict;
use warnings;
use Net::Google::Code '0.19';
use Net::GitHub '0.21';
use Data::Dumper;

my($gc_proj, $gh_proj) = @ARGV;

my %github;
@github{qw( owner repo )} = split '/', $gh_proj;

chomp($github{login} = `git config github.user`);
chomp($github{token} = `git config github.token`);

my $code = Net::Google::Code->new(project => $gc_proj);
my $github = Net::GitHub->new(%github);

my @closed_statii = qw(
	Fixed
	Verified
	Invalid
	Duplicate
	WontFix
);

for my $issue ( $code->issue->list() ) {

	my $desc_with_user =
		"Originally filed by " . $issue->reporter . " on " . $issue->reported
		. "\n\n"
		. $issue->description();

	my $gh_issue = $github->issue->open($issue->summary, $desc_with_user);
	warn $issue->id() . " -> " . $gh_issue->{number};

	if( ! $gh_issue->{number} ) {
		# WTF.
		die Dumper $gh_issue;
	}

	# Labels
	foreach my $label ( @{ $issue->labels } ) {
		$github->issue->add_label( $gh_issue->{number}, $label );
	}

	# Comments
	$issue->load_comments();
	foreach my $comment (@{ $issue->comments }) {
		if( $comment->updates ) {
			if (exists $comment->updates->{labels} ) {
				foreach ( @{ $comment->updates->{labels} } ) {
					if( s/^-// ) {
						$github->issue->remove_label( $gh_issue->{number}, $_);
					} else {
						$github->issue->add_label( $gh_issue->{number}, $_);
					}
				}
			}
			# TODO other updates
			warn Dumper $comment->updates if $comment->updates;
		}
		next unless $comment->content;
		my $comment_with_user = "Original comment by " . $comment->author . " on " . $comment->date . "\n\n" . $comment->content();
#		$github->issue->comment($gh_issue->{number}, $comment_with_user);
	}

	if( grep { $_ eq $issue->status } @closed_statii ) {
#		$github->issue->close( $gh_issue->{number} );
	}

	# TODO attachments?

	sleep (2);
}
