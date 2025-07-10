#!/usr/bin/perl
use strict;
use warnings;
use utf8;
binmode STDIN,  ':encoding(UTF-8)';
binmode STDOUT, ':encoding(UTF-8)';
binmode STDERR, ':encoding(UTF-8)';
use DBI;

my $dbfile = "dictionary.db";

unless (-f $dbfile) {
    print "Database '$dbfile' not found. Creating and populating...\n";
    my $dbh_init = DBI->connect("dbi:SQLite:dbname=$dbfile","","", { RaiseError => 1, AutoCommit => 1 })
        or die "Cannot create DB: $!";

    $dbh_init->do("CREATE VIRTUAL TABLE dictionary USING fts5(lang_from, lang_to, phrase_from, phrase_to)")
        or die "Failed to create FTS5 table";

    my @entries = (
        # Spanish
        ['es', 'en', 'hola', 'hello'],
        ['es', 'en', 'mañana', 'morning'],
        ['es', 'en', 'adiós', 'goodbye'],
        ['es', 'en', 'el gato', 'the cat'],
        ['es', 'en', 'el perro', 'the dog'],
        # German
        ['de', 'en', 'schön', 'beautiful'],
        ['de', 'en', 'grüß dich', 'greetings to you'],
        ['de', 'en', 'ich liebe dich', 'i love you'],
        # French
        ['fr', 'en', 'bonjour', 'hello'],
        ['fr', 'en', 'le chat est noir', 'the cat is black'],
        ['fr', 'en', 'monde', 'world'],
        # Danish/Nordic examples
        ['da', 'en', 'hej', 'hello'],
        ['da', 'en', 'fisk', 'fish'],
        ['da', 'en', 'smørrebrød', 'open-faced sandwich'],
        ['no', 'en', 'takk', 'thanks'],
        ['no', 'en', 'fjord', 'fjord'],
        ['sv', 'en', 'fågel', 'bird'],
        # Finnish
        ['fi', 'en', 'kiitos', 'thank you'],
        ['fi', 'en', 'sisu', 'guts, determination'],
        # Estonian
        ['et', 'en', 'tere', 'hello'],
        ['et', 'en', 'õlu', 'beer'],
        # Latvian
        ['lv', 'en', 'paldies', 'thank you'],
        ['lv', 'en', 'jūra', 'sea'],
        # Lithuanian
        ['lt', 'en', 'labas', 'hello'],
        ['lt', 'en', 'vanduo', 'water'],
    );

    my $sth = $dbh_init->prepare("INSERT INTO dictionary VALUES (?, ?, ?, ?)");
    for my $e (@entries) {
        $sth->execute(@$e);
    }

    $dbh_init->disconnect;
    print "Database created and populated.\n";
}

my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","", { RaiseError => 1, AutoCommit => 1 })
    or die "Cannot connect to DB '$dbfile': $!";

my ($lang_from, $lang_to) = @ARGV;
die "Usage: $0 <lang_from> <lang_to>\n" unless $lang_from && $lang_to;

print "Enter text to translate from $lang_from to $lang_to (empty line to quit):\n";

while (my $input = <STDIN>) {
    chomp $input;
    last if $input eq '';

    my $input_lc = lc $input;

    # 1) Try exact phrase translation first
    my $sth = $dbh->prepare("SELECT phrase_to FROM dictionary WHERE lang_from = ? AND lang_to = ? AND phrase_from = ?");
    $sth->execute($lang_from, $lang_to, $input_lc);
    my ($exact_translation) = $sth->fetchrow_array;

    if ($exact_translation) {
        $exact_translation = ucfirst $exact_translation if $input =~ /^\p{Lu}/;
        print "Exact translation found:\n$exact_translation\n";
        next;
    }

    # 2) No exact match, try FTS full-text search (loose fuzzy)
    my $fts_query = $input_lc;
    $fts_query =~ s/[^\p{Latin}0-9 ]//g;  # keep only Latin letters, digits, spaces

    my $sth_fts = $dbh->prepare("SELECT phrase_from, phrase_to FROM dictionary WHERE lang_from = ? AND lang_to = ? AND dictionary MATCH ?");
    $sth_fts->execute($lang_from, $lang_to, $fts_query);

    my @matches;
    while (my $row = $sth_fts->fetchrow_hashref) {
        push @matches, $row;
    }

    if (@matches) {
        print "Possible matches:\n";
        my $i = 1;
        for my $m (@matches) {
            print "[$i] $m->{phrase_from} => $m->{phrase_to}\n";
            $i++;
        }
        print "Select number for translation or 0 to skip: ";
        chomp(my $choice = <STDIN>);
        if ($choice =~ /^\d+$/ && $choice > 0 && $choice <= @matches) {
            print "Selected translation:\n" . $matches[$choice-1]->{phrase_to} . "\n";
        } else {
            print "No selection made. You can try another input.\n";
        }
        next;
    }

    # 3) No fuzzy matches, fallback to word-by-word translation (Latin letters incl accents)
    my @words = split /(\W+)/, $input;
    for my $w (@words) {
        if ($w =~ /^\p{Latin}+$/) {
            my $lc_word = lc $w;
            my $sth_word = $dbh->prepare("SELECT phrase_to FROM dictionary WHERE lang_from=? AND lang_to=? AND phrase_from=?");
            $sth_word->execute($lang_from, $lang_to, $lc_word);
            my ($word_translation) = $sth_word->fetchrow_array;
            if ($word_translation) {
                $word_translation = ucfirst $word_translation if $w =~ /^\p{Lu}/;
                $w = $word_translation;
            }
        }
        # else leave punctuation/non-latin untouched
    }
    print join('', @words), "\n";
}
