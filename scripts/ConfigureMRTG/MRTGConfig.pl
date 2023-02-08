require "../Routines.pl";
use Config::File;
use Data::Dumper;
use Path::Tiny;
use Config::Crontab;

my $cf = Config::File::read_config_file('../.env');


if ($#ARGV != 1 ) {
	print "uso ConfigureMRTG.pl TIPO [MPLS] Abreviacion de la oficina o ALL para TODAS ".$#ARGV." \n";
	exit;
}



my @ofi;
if ($ARGV[1] eq "ALL") {
	@ofi=getmplsbranches();	
} else {
	push (@ofi, $ARGV[1]);
}

#print Dumper @ofi;
#sleep 44;

if ($ARGV[0] eq "MPLS") {
	foreach my $value ( @ofi ) {
	    print $value;
	    my $cmda="mkdir ".$cf->{MPLSMRTGPATH}."/".$value;
	    my @outa = qx($cmda);
	    my $cmd="/usr/bin/cfgmaker pitictransportes\@MPLS_".$value." > ".$cf->{MPLSMRTGPATH}."/".$value."/".$value.".cfg";
	    my @outb = qx($cmd);
	    print Dumper @outb."\n";
		my $wdval = "WorkDir: ".$cf->{MPLSMRTGPATH}."/".$value."\n";
		my $conf = $cf->{MPLSMRTGPATH}."/".$value."/".$value.".cfg";
		my $content = path($conf)->slurp_utf8;
		my $op = 'Options[_]: growright, bits'."\n";
		path($conf)->spew_utf8($op, $content);
		my $contentb = path($conf)->slurp_utf8;
		path($conf)->spew_utf8($wdval, $contentb);
		my $cmdc="/usr/bin/indexmaker ".$cf->{MPLSMRTGPATH}."/".$value."/".$value.".cfg > ".$cf->{MPLSMRTGPATH}."/".$value."/index.html";
		my @outc = qx($cmdc);
		my $ct = new Config::Crontab;
		$ct->read;
		my $event = new Config::Crontab::Event( -minute  => 5,
	                                         	-command => "env LANG=C /usr/bin/mrtg ".$cf->{MPLSMRTGPATH}."/".$value."/".$value.".cfg");
		$block = new Config::Crontab::Block;
		$block->last($event);
		$ct->last($block);
		$ct->write;
	}
}

