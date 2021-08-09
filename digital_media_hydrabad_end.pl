#!/usr/bin/perl -w

BEGIN {
        unshift(@INC,'/uc/lib/modules/','/uc/lib/perl/');
#        print "@INC \n";
};

use Ivr::DialPlanApi;
use Asterisk::AGI;
use Config::INI::Reader;
use DBI;
use HTTP::Request::Common;
use LWP::UserAgent;


sub __update_status{

	my ($config,$default_values,$mem_obj) = @_;
        my $mobileno_length = length($mem_obj->{'callerid'});
	my $mobile_no;
        my $date;
	my $time;
	my $day;
        my $Time_Session;
	my $weekday;
        my $productkey;
	my $key_pressed;
	my $call_start_time;
        my $key_status = 0;
        my $flag_status;
        my $campaign = 'MOHO HYDERABAD BTL';
	if ($mobileno_length > 10)
	{
		my $n = 2;
        	$mem_obj->{'callerid'} = substr( "$mem_obj->{'callerid'}",$n);  
        	
	}
	my $customer_no = $mem_obj->{'callerid'};
         my $filename = '/var/log/asterisk/finserv_report.txt';
       open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
        print $fh " customer_end=$customer_no \n";
        close $fh;

       # ========================================================================
	my $value = 1;
	my $dbh = DBI->connect("dbi:mysql:database=asterisk;host=localhost","root","mys\@r0ja");
	my $query = "select mobile_no,date,time,day,Time_Session,weekday from digitalmedia_hydrabad where mobile_no = $customer_no order by id desc limit 1";
	my $sth = $dbh->prepare($query) ;
        my  $ret =$sth->execute();
	while(my @row = $sth->fetchrow_array())
        {
              $mobile_no         =      $row[0];
              $date     	 =      $row[1];
	      $time              =      $row[2];
	      $day               =      $row[3];
              $Time_Session      =      $row[4];
	      $weekday           =      $row[5];
	     
        }
        $sth->finish();  #24/08/16
        $dbh->disconnect();
        my $city_option = 5;
        my $ua = LWP::UserAgent->new(ssl_opts => { verify_hostname => 0}, );
        my $req = GET "https://www.rubicsolution.in/gayatri/gayatri_lead_api.php?mobile_no=$mobile_no&date=$date &time=$time&day=$day &Time_Session=$Time_Session&campaign=$campaign&weekday=$weekday&productkey=$city_option";
        my $res = $ua->request($req);
	if ($res->is_success) {
                        print $res->content;
			my $filename = '/var/log/asterisk/finserv_report.txt';
                open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
                print $fh "Response is sucessful for https://www.rubicsolution.in/gayatri/gayatri_lead_api.php?mobile_no=$mobile_no&date=$date &time=$time&day=$day &Time_Session=$Time_Session&campaign=$campaign&weekday=$weekday \n";
               close $fh;
                }else{
                        print $res->status_line . "\n";
			my $filename = '/var/log/asterisk/finserv_report.txt';
                	open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
                	print $fh "Response is not sucessful for https://www.rubicsolution.in/gayatri/gayatri_lead_api.php?mobile_no=$mobile_no&date=$date &time=$time&day=$day &Time_Session=$Time_Session&campaign=$campaign&weekday=$weekday \n";
                close $fh;

                	}
        return "exit";
     
}




sub main {

	my (${CID},${DIALSTATUS}) = @ARGV;
	my $AGI = new Asterisk::AGI;
        my (%output) = $AGI->ReadParse();
	my $config = {
		'_cti_obj' => $AGI,
		'_db' => 1
	};
	my %value_hash;
        my $default_values = {
		'timeout' => '3000',
		'timeout_count' => '2',
		'timeout_file' => undef,
		'timeout_max' => undef,
		'invalid_count' => '2',
		'invalid_file' => undef,
		'invalid_max' => undef
	};

	my $mem_obj = {
		'callerid' => ${CID},
		'dialed_status' => ${DIALSTATUS}
	};
		
	my $function = "__update_status";
	my $loop = 1;
	do {
		my ($next_action) = &{$function}($config,$default_values,$mem_obj);
		$AGI->exec("NoOP","Previous=$function===Next==$next_action");
		if ($next_action eq "exit") {
			$loop = 0;
		}
		$function = $next_action;

	} while ($loop);
	return -1;

}

sub read_ini_file {
		my ($filename,$hashref) = @_;
		my $tmphashref;
		$tmphashref = Config::INI::Reader->read_file($filename); 
		%{$hashref} = %{$tmphashref};
}

main();
exit;
