#!/usr/bin/perl

use 5.010;
use strict;
use warnings;
use WebService::HipChat;

# read config file
my $config = 'config';
my $flag;
my @settings;
my @contacts;
open my $fh, '<', $config or die "Cannot open config file!\n";
foreach my $line (<$fh>) {
	next if ($line =~ /^$/);
	if ($line =~ "settings") {
		$flag = 'settings';
		next;
	} elsif ($line =~ "contacts") {
		$flag = 'contacts';
		next;
	}
	if ($flag =~ 'settings') {
		push @settings, $line;
	} elsif ($flag =~ 'contacts') {
		push @contacts, $line;
	}
}
close $fh;

# populate the phone book
my %phonebook;
foreach my $i (@contacts) {
	my @person = split (/=/, $i);
	chomp($person[1]);
	$phonebook{$person[0]} = $person[1];
}

# split out auth token from config
my @auth = split(/=/, $settings[0]);
my $token = $auth[1];

# print usage if args invalid
my $usage = "USAGE: pub emoji_keyword user_id\n";
# if (scalar @ARGV < 2) { print $usage ; exit };

# gather variables using args or stdin
my $EMOJI;
my $userinput;
my $user;
if (scalar @ARGV == 2) {
	$EMOJI = $ARGV[0];
	$userinput = $ARGV[1];
} else {
	say "Please enter name of contact: (or \"list\" to list current contacts, or \"add\" to add a new one)";
	$userinput = <STDIN>;
	chomp($userinput);
}

# check for list or add commands
$userinput = uc $userinput;
if ($userinput =~ "LIST") {
	phone_list();
	exit;
}
if ($userinput =~ "ADD") {
	say "Please enter alias for user:";
	my $alias = <STDIN>;
	chomp($alias);	
	say "Please enter id:";
	my $id = <STDIN>;
	chomp($id);
	contact_add($alias,$id);
	say "User \"$alias\" added successfully!";
	exit;
}

# pick emoji to use
say "Please enter emoji to use:";
	$EMOJI = <STDIN>;
	chomp($EMOJI);

#check userinput against phonebook
if (exists $phonebook{$userinput}) {
	$user = $phonebook{$userinput};
} else {
	say "Contact not found, please try again.";
	exit;
}

# construct a meaty pub message
my $message = << "EOF";
($EMOJI)($EMOJI)($EMOJI)
($EMOJI)        ($EMOJI)
($EMOJI)($EMOJI)($EMOJI)
($EMOJI)
($EMOJI)

($EMOJI)        ($EMOJI)
($EMOJI)        ($EMOJI)
($EMOJI)        ($EMOJI)
($EMOJI)        ($EMOJI)
($EMOJI)($EMOJI)($EMOJI)

($EMOJI)($EMOJI)($EMOJI)
($EMOJI)        ($EMOJI)
($EMOJI)($EMOJI)($EMOJI)
($EMOJI)        ($EMOJI)
($EMOJI)($EMOJI)($EMOJI)
EOF

# post to given hipchat person
my $hc = WebService::HipChat->new(auth_token => $token );
$hc->send_private_msg($user, { message => $message });
say "PUB SALUTATIONS sent to $userinput!";

### SUBFUNCTIONS GO HERE ###
sub phone_list {
	foreach (keys %phonebook) {
 		say "$_ - " . $phonebook{$_};
	 }
}

sub contact_add {
	my $config = 'config';
	my @newuser = @_;
	my @newlines;
	open my $fh, '<', $config or die "Cannot open config file!\n";
	foreach my $line (<$fh>) {
		unless ($line =~ "/contacts") {
			push @newlines, $line;
		}
	}
	my $new = uc $newuser[0] . "=" . $newuser[1] . "\n";
	my $end = "</contacts>\n";
	push @newlines, $new;
	push @newlines, $end;
	close $fh;
	open $fh, '>', $config or die "Cannot open config file!\n";
	foreach my $i (@newlines) {
		print $fh $i;
	}
	close $fh;
}	
