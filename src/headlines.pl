#!/usr/bin/perl -w

use strict;
use warnings;
use WWW::Mechanize ();
use HTML::TreeBuilder;
use File::HomeDir;
use File::Slurp;
use open            qw( :std :encoding(UTF-8) );
use Term::ANSIColor qw(:constants);
use Scalar::Util    qw(looks_like_number);

$Term::ANSIColor::AUTORESET = 1;

sub help_dialog {
    print("Usage: perl headlines.pl [n] [page]\n");
    print("n = The amount of articles you want to preview\n");
    print("page = Optional parameter to select active or recent pages\n");
    print(
"\nBlock articles with undesired subjects using ~/.lobsters_blacklist with one word per newline."
    );
    exit 0;
}

sub get_home_path {
    return File::HomeDir->my_home;
}

sub if_blacklist {
    my $blacklist_location = get_home_path() . "/.lobsters_blacklist";

    if ( -e $blacklist_location ) {
        my $blacklist_content =
          read_file( $blacklist_location, { chomp => 1 } );
        return split /\n/, $blacklist_content;
    }
    else {
        return ();
    }
}

my $selected_page = 'recent';
my $limit;

if (@ARGV) {
    my $argv_count = scalar @ARGV;
    help_dialog() if ( $ARGV[0] eq '-h' );
    if ( @ARGV > 1 ) {
        $selected_page = $ARGV[1] if ( $ARGV[1] eq 'active' );
    }
    $selected_page = $ARGV[0] if ( $ARGV[0] eq 'active' );
    $limit         = $ARGV[0] if ( looks_like_number( $ARGV[0] ) );
    $limit         = 5        if ( !looks_like_number( $ARGV[0] ) );
}
else {
    help_dialog();
}

my $mech = WWW::Mechanize->new();
my $url  = 'https://lobste.rs/';
$url = $url . $selected_page;

my $baseUrl = 'https://lobste.rs';
$mech->get($url);

my $tree     = HTML::TreeBuilder->new_from_content( $mech->content() );
my @articles = $tree->look_down( _tag => 'li' );

my $i = 0;
print BOLD YELLOW "-= Headlines =-\n\n";
foreach my $article (@articles) {
    my $entry = $article->as_text;
    my $link  = $article->look_down( _tag => 'a', class => 'u-url' );
    my $href  = $link ? $link->attr('href') : 'Broken URL';
    $entry =~ s/\|.*//;
    $entry =~ s/\s{2,}.*//;

    for ( my $j = 0 ; $j < 3 ; $j++ ) {
        if ( looks_like_number( substr( $entry, $j, 1 ) ) ) {
            $entry =~ s/^.//s;
        }
    }

    $href = $baseUrl . $href if ( substr( $href, 0, 3 ) eq "/s/" );

    no warnings 'numeric';
    if ( defined if_blacklist() && scalar( if_blacklist() ) > 0 ) {
        for my $line ( if_blacklist() ) {
            if ( index( lc($entry), lc($line) ) != -1 ) {
                $entry = "redact";
            }
        }
    }

    if ( !( $entry eq "redact" ) ) {
        print BOLD RED "[$selected_page] $entry\n";
        print BOLD GREEN "URL: $href\n";
        print "\n";
    }

    ++$i;
    exit 0 if ( $i > $limit );
}

$tree->delete;
