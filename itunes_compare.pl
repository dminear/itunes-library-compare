#!/usr/bin/perl -w

use strict;
use FileHandle;
use File::Slurp;
use v5.10;
use Data::Dumper;

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
@worklist = map { "scp \"dan\@ubuntu:/mnt/user_data/dan_data/Music/iTunes/Music/$_\" \"import/$_\"\n"} @worklist;
write_file("copy.sh", @worklist);