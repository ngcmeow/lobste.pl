#!/usr/bin/perl -w

use strict;
use warnings;
use WWW::Mechanize ();
use HTML::TreeBuilder;
use open qw( :std :encoding(UTF-8) );
use Term::ANSIColor qw(:constants);
use Scalar::Util qw(looks_like_number);

$Term::ANSIColor::AUTORESET = 1;

sub help_dialog {
    print("Usage: perl headlines.pl [n] [page]\n");
    print("n = The amount of articles you want to preview\n");
    print("page = Optional parameter to select active or recent pages\n");
    exit 0;
}

my $selected_page = 'recent';
my $limit;

if (@ARGV) {
    my $argv_count = scalar @ARGV;
    help_dialog() if ($ARGV[0] eq '-h');
    if (@ARGV > 1) {
        $selected_page = $ARGV[1] if ($ARGV[1] eq 'active');
    }
    $selected_page = $ARGV[0] if ($ARGV[0] eq 'active');
    $limit = $ARGV[0] if (looks_like_number($ARGV[0]));
    $limit = 5 if (!looks_like_number($ARGV[0]));
} else {
    help_dialog();
}

my $mech = WWW::Mechanize->new();
my $url = 'https://lobste.rs/';
$url = $url . $selected_page;

my $baseUrl = 'https://lobste.rs';
$mech->get($url);

my $tree = HTML::TreeBuilder->new_from_content($mech->content());
my @articles = $tree->look_down(_tag => 'li');

my $i = 0;
print BOLD YELLOW "-= Headlines =-\n\n";
foreach my $article (@articles) {
    my $entry = $article->as_text;
    my $link = $article->look_down(_tag => 'a', class => 'u-url');
    my $href = $link ? $link->attr('href') : 'Broken URL';
    $entry =~ s/\|.*//;
    $entry =~ s/\s{2,}.*//;

    $href = $baseUrl . $href if (substr($href, 0, 3) eq "/s/");

    print BOLD RED "[$i] $entry\n";
    print BOLD GREEN "URL: $href\n";
    print "\n";

    ++$i;
    exit 0 if ($i > $limit);
}

$tree->delete;
