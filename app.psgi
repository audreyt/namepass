#!/usr/bin/env perl
use 5.12.0;
use utf8;
use Encode;
use List::Util 'shuffle';
use Furl;
use File::Slurp;
use JSON;

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
    my $body = Encode::encode_utf8(<<".");
<!doctype html>
<html><head>
<link href="http://www.perlbrew.pl/stylesheets/application.css" media="screen, projection" rel="stylesheet" type="text/css">
<style>
body { font-family: "Microsoft JhengHei", "Apple LiGothic", "Droid Sans Fallback", sans-serif }
h1 { font-size: 24pt }
td { font-size: 20pt }
.title {
    background: #ffd893;
    padding: 10px;
    border-radius: 10px;
    color: #116 !important;
}
.title:hover {
    color: #c3c !important;
}
</style>
</head><body><center>
<h1 style="padding-top: 100px; padding-bottom: 50px"><a href="/" class="title" title="產生一組新的人名密碼">密碼歐陽盆栽</a></h1>
<table><tr>
<td>姓名</td><td>$name</td>
</tr><tr><td>嘸蝦米</td><td><tt>$code{boshiamy}</tt></td>
</tr><tr><td>大易三</td><td><tt>$code{dayi}</tt></td>
</tr><tr><td>快倉七</td><td><tt>$code{scj7}</tt></td>
</tr><tr><td>行列26</td><td><tt>$code{array26}</tt></td>
</tr></table></body></html>

<footer>
    <p>源碼在 <a href="https://github.com/audreyt/namepass/">GitHub</a> 上，以 <a href="http://creativecommons.org/publicdomain/zero/1.0/deed.zh_TW">CC0 無著作權方式</a> 釋出。
    </p><p>
    感謝 <nobr>perlbrew.pl 的 <a href="http://www.perlbrew.pl/stylesheets/application.css">樣式表</a></nobr>，
         <nobr>richyli.com 的 <a href="http://www.richyli.com/name/">人名表</a></nobr>，
         <br>
         <nobr>openvanilla.org 的 <a href="http://openvanilla.googlecode.com/svn/trunk/Modules/SharedData/">字碼表</a></nobr>，以及
         <nobr>edu.tw 的 <a href="http://www.edu.tw/mandr/download.aspx?download_sn=306&pages=2&site_content_sn=3364">常用字表</a>。</nobr>:-)</p>
</footer>
.
    return [200, ['Content-Type' => 'text/html; charset=utf-8', 'Content-Length' => length $body], [$body]]
}
