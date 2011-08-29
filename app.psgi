#!/usr/bin/env perl
use 5.12.0;
use utf8;
use Encode;
use List::Util 'shuffle';
use Furl;
use File::Slurp;
use JSON;

my $Template = read_file('index.html', {binmode => ':utf8'});
my @IM = qw( dayi scj7 array26 boshiamy );
my %Maps = map { $_ => decode_json(read_file("$_.json", binmode => ':raw')) } @IM;

sub getNextFamily {
    state @families;
    return shift(@families) if @families;
    @families = shuffle(split(//, "丁丘于任伍何佘余佟侯俞倪傅儲全兵冉刁利劉勞包匡區卓卜卞叢古史司向吳呂周唐商喬單喻嚴夏姚姜姬婁孔孟季孫安宋宗官宮寧尚尤尹屈屠岑岳崔左巫巴席常幸康廖張彭徐應成戚戴房文方施易時晏曲曹曾朱李杜林柏查柯柳柴桂桑梁梅楊榮樂樊樓歐武段殷毛江池汪沉沙洪涂淩湯溫潘焦熊牛牟王甘田申留畢白盛盧瞿石祁祝秦程穆竇章童符管簡籃粘紀練繆羅翁翟耿聞聶胡臧舒艾花苗范莊莫華萬葉葛董蒙蒲蔡蔣蕭薛藍蘇蘭虞衛袁裘裴褚覃解許詹談謝譚谷費賀賈賴趙路車辛辜連遊邊邢邱邵郎郝郭鄒鄔鄧鄭鄺金錢鐘閔閻闕關阮陳陶陸陽隋雷霍韋韓項顏顧風饒馬馮駱高魏魯鮑麥黃黎齊龍龐龔"));
    return shift(@families);
}

sub getNextName {
    state @names;
    return shift(@names) if @names;

    my $res = Furl->new->post(
        'http://www.richyli.com/name/index.asp', [],
        [name_count => 500, yourname => ' ', break => 3]
    );

    my $content = Encode::decode(big5 => $res->content);
    $content =~ s/.*<tr><td valign="top">\s*//s;
    $content =~ s/\s*<BR>＃.*//s;
    @names = split(/\s*<BR>\s*/, $content);

    return shift(@names);
}

sub {
    my ($name, %code);
GEN: while (1) {
        $name = getNextFamily() . getNextName();
        for my $im (@IM) {
            $code{$im} = join(' ', map { $Maps{$im}{$_} // next GEN } split(//, $name));
        }
        last;
    }

    my $body = $Template;
    $body =~ s!\$name!$name!g;
    $body =~ s!\$code{(\w+)}!$code{$1}!g;
    $body = Encode::encode_utf8($body);

    return [200, ['Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => length $body], [$body]]
}
