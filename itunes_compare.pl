#!/usr/bin/perl -w

use strict;
use FileHandle;
use File::Slurp;
use v5.10;
use Data::Dumper;
use File::Copy;
use File::Path qw(make_path);

my @clib = read_file("cindy-itunes.txt");
my @dlib = read_file("dan-itunes.txt");

chomp @clib;
chomp @dlib;

say "There are " . @clib . " files in Cindy's library";
say "There are " . @dlib . " files in Dan's library";

# strip off ./iTunes Media/Music
my @clib2 = map { s/^\.\/iTunes Media\/Music/\./; $_ } @clib;

# only look at the Music
my @dlib2 = grep { /^\.\/iTunes\/Music/ } @dlib;

say "Now there are " . @dlib2 . " music files to check";

my @dlib3 = map { s/^\.\/iTunes\/Music/\./; $_ } @dlib2;

# now we have things in compatible format...

# shove all Cindy's entries into a hash
my $chash = {};
foreach (@clib2) {
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

my @badext = qw/png jpg mov plist css js html txt xml itlp DS_Store pdf aif 0 5 King M_ S_/;
foreach my $ext (@badext) {
    @worklist = map {/\.$ext$/ ? '': $_} @worklist;  # remove bad extention files
}

# remove things that don't have an extension
@worklist = map { /\.\w+$/ ? $_ : '' } @worklist;

# remove dupes of Sharon Isbin
@worklist = map { /Sharon Isbin/ ? '' : $_ } @worklist;

@worklist = map { /Grace Under Pressure\/.+\.m4p$/ ? '' : $_ } @worklist;
@worklist = map { /We Can't Dance/ ? '' : $_ } @worklist;
@worklist = map { /Eric Uglum/ ? '' : $_ } @worklist;
@worklist = map { /Feels Like Home/ ? '' : $_ } @worklist;
@worklist = map { /Queen\/Queen_ Greatest Hits/ ? '' : $_ } @worklist;
@worklist = map { /Live at The Mauch/ ? '' : $_ } @worklist;
@worklist = map { /Southern Accents/ ? '' : $_ } @worklist;
@worklist = map { /Who Are You/ ? '' : $_ } @worklist;
@worklist = map { /Songs of Innocence/ ? '' : $_ } @worklist;
@worklist = map { /Afterglow/ ? '' : $_ } @worklist;
@worklist = map { /The Essential 3.0/ ? '' : $_ } @worklist;
@worklist = map { /Waking Up The Neighbours/ ? '' : $_ } @worklist;

@worklist = map { /\/\._/ ? '' : $_ } @worklist; # remove mac resouce files

@worklist = grep { /.+/ } @worklist; # only take lines with something

say "A total of " . @worklist . " items not found after removing stuff";

# now put them in buckets
my %h;
foreach my $i (@worklist) {
    $i =~ /\.(\w+)$/;
    push @{$h{$1}}, $i;
}

say "extensions are " . join( " ", sort keys(%h));
# extensions are MP3 WAV m4a m4p mp3 wav

# all files good now!

write_file( "output.txt", sort @worklist);
# now copy these into a folder to import into Cindy's iTunes
chomp @worklist;
@worklist = map { "/Users/dan/Music/iTunes/Music/$_" } @worklist;
write_file("fullpath.txt", join( "\n", @worklist, ""));

# see if these files exist
foreach (@worklist) {
    if (! -e $_) {
        say "NOT THERE: $_";
    } else {
	my $orig = $_;
	say "orig: $orig";
	$orig =~ /^\/Users\/dan\/Music\/iTunes\/Music\/\.\/(.+)\/(.+\.\w+)$/;
	my $path = "import/" . $1;
	my $file = $2;
	make_path( $path ); 
	say "copy $1 -- $2";
        copy( $_, $path . "/" . $file) or die "Failed: $!";
    }
}

# now the import dir has the files to be imported into the master library

