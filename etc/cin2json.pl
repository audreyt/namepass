use utf8;
use File::Slurp;
use JSON;
use Encode;
use 5.14.0;

my (%c2t, %t2c);

while (<>) {
    next unless /%chardef begin/ .. /%chardef end/;
    chomp;
    my ($code, $text) = split(/\s+/, Encode::decode_utf8($_));
    $code = lc $code;
    push(($c2t{$code}||=[]), $text);
    push(($t2c{$text}||=[]), $code);
}

my $common = read_file('common.txt', 'binmode' => ':utf8');
$common =~ s/\s//g;
my %final;
for (split //, $common) {
    my $cs = $t2c{$_} or next;
    if (@$cs == 1) {
        $final{$_} = $cs->[0];
    }
    else {
        $final{$_} = (sort {
            (@{$c2t{$a}} <=> @{$c2t{$b}})
                or
            (length $a <=> length $b)
        } @$cs)[0];
    }
}
print encode_json(\%final);
