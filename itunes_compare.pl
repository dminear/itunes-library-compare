#!/usr/bin/perl -w

use strict;
use FileHandle;
use File::Slurp;
use v5.10;

my @clib = read_file("cindy-itunes.txt");
my @dlib = read_file("dan-itunes.txt");

chomp @clib;
chomp @dlib;

say "There are " . @clib . " files in Cindy's library";
say "There are " . @dlib . " files in Dan's library";

# only look at the Music
my @dlib2 = grep { /^\.\/iTunes\/Music/ } @dlib;

say "Now there are " . @dlib2 . " music files to check";

my @dlib3 = map { s/^\.\/iTunes\/Music/\./; $_ } @dlib2;

# now we have things in compatible format...

# shove all Cindy's entries into a hash
my $chash = {};
foreach (@clib) {
    $chash->{$_}++;
}
say "there are " . keys(%$chash) . " keys in chash";

# now go through dlib3
my @worklist;
foreach (@dlib3) {
    if (! exists $chash->{$_}) {
        push @worklist, $_ . "\n";
    } else {
        ;
    }
}
say "A total of " . @worklist . " items not found";

write_file( "output.txt", @worklist);
