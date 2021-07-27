#!/usr/bin/perl -w

BEGIN {
        unshift(@INC,'/uc/lib/modules/','/uc/lib/perl/');
#        print "@INC \n";
};

use Ivr::DialPlanApi;
use Asterisk::AGI;
use Config::INI::Reader;
use DBI;
use Time::Local;

sub __edas_welcome
{
  	my ($config,$default_values,$mem_obj) = @_;
	my $weekday;
        my $day_is;
	my $zone;
	my $time_now;
	my $media_channel;
        my $lead_source;
	my $series_idea;
	my ($sec,$min,$hour,$date,$mon,$year,$wday,$yday,$isdst) = localtime();
	if($wday == 0)
        {
                $weekday = 'Sun';
        }
        elsif($wday == 1)
        {
                $weekday = 'Mon';
        }
        elsif($wday == 2)
        {
                $weekday = 'Tue';
        }
        elsif($wday == 3)
        {
                $weekday = 'Wed';
        }
        elsif($wday == 4)
        {
                $weekday = 'Thu';
        }
        elsif($wday == 5)
        {
                $weekday = 'Fri';
        }
        else
        {
                $weekday = 'Sat';
        }
        $weekday = uc $weekday;
        if($wday == 0 || $wday == 6)
        {
                $day_is = "Weekend";
        }
        else
        {
                $day_is = "Weekday"
        }
         $day_is = uc $day_is;
	 $year +=1900;
         $mon  +=1;
         my $current_date = sprintf("%04d-%02d-%02d",$year,$mon,$date);
         my $current_time = sprintf("%02d:%02d:%02d",$hour,$min,$sec);
         my $call_start_time = sprintf("%02d:%02d:%02d",$hour,$min,$sec);
	 my $time_display = sprintf("%02d%02d%02d",$hour,$min,$sec);
        if ($time_display >= '210000' && $time_display < '235959')
        {
                $time_now = "NIGHT";
        }
	if ($time_display > '235959' && $time_display < '040000')
        {
                $time_now = "NIGHT";
        }

        if ($time_display >= '040000' && $time_display < '120000')
        {
                $time_now = "MORNING";
        }
        if ($time_display >= '120000' && $time_display < '160000')
        {
                $time_now = "AFTERNOON";
        }
        if ($time_display >= '160000' && $time_display < '210000')
        {
                $time_now = "EVENING";
        }
	my $mobileno_length = length($mem_obj->{'callerid'});
        if ($mobileno_length > 10)
	{
		my $n = 2;
        	$mem_obj->{'callerid'} = substr( "$mem_obj->{'callerid'}",$n);  
        	
	}	
	my $callerid = $mem_obj->{'callerid'};
        my $uniqueid = $mem_obj->{'session_id'};
	$series_idea = substr($callerid, 0, 2);
        if($series_idea == 14)
        {
                return "exit";
        }
	 my $tablename = 'edas_test';
	 my $dbh = DBI->connect("dbi:mysql:database=asterisk;host=localhost","root","Mys\@roja2021");
         my $count =0;
	 
         my $query = "INSERT INTO $tablename (mobile_no,date,time,day,Time_Session,campaign,weekday,unique_id) VALUES('$callerid','$current_date','$current_time','$weekday','$time_now','EDAS','$day_is','$uniqueid')";
         my $sth = $dbh->prepare($query) ;
         my $ret =$sth->execute();
         $dbh->disconnect();
         $config->{_cti_obj}->exec("Playback","demo-echotest");
	return("__check_option");
}

sub __check_option
{
        my ($config,$default_values,$mem_obj) = @_;
	my $bg_sound_file = "/home/amit/media_rec-3";
        my $callerid = '8369854211';
        my $circle_id;
	my $max_allowed_digit = "1";
	my $hash_table_ref = {
			'1' => '1',
	        	'2' => '2' 
	};
        my $dtmf = Ivr::DialPlanApi::apps_background_hash($config->{_cti_obj},$bg_sound_file,$max_allowed_digit,$default_values->{'timeout'},$default_values->{'timeout_count'},$default_values->{'timeout_file'},$default_values->{'timeout_max'},$default_values->{'invalid_count'},$default_values->{'invalid_file'},$default_values->{'invalid_max'},$hash_table_ref);
        $config->{_cti_obj}->exec("SayDigits","$dtmf");
      #  if($dtmf != 1 || $dtmf !=2)
      #  {
#		$dtmf = 'INVALID';
 #       }

        my $tablename = 'edas_test';
        my $dbh_1 = DBI->connect("dbi:mysql:database=asterisk;host=localhost","root","Mys\@roja2021");
        my $count =0;
        my $query_1 =  "update $tablename set keyinput = '$dtmf' order by id desc limit 1";
        my $sth_1 = $dbh_1->prepare($query_1) ;
        my $ret_1 =$sth_1->execute();
        $sth_1->finish();
        $dbh_1->disconnect();
        my $filename = '/var/log/asterisk/edas_report.txt';
        open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
        print $fh "Response is sucessful for $query_1 \n";
        close $file;
        $circle_id = `python3 /home/amit/getcircle.py $callerid`;
        sleep(1);
        my $filename = '/var/log/asterisk/edas_report.txt';
        open(my $fh, '>>', $filename) or die "Could not open file '$filename' $!";
        print $fh "Query for python is `python3 /home/amit/getcircle.py $callerid \n";
        close $file;
        if($circle_id == 24)
        {
        	$config->{_cti_obj}->exec("Playback","demo-echotest");
	}
        return("exit")
}


sub main {

	my ($did) = @ARGV;
	my $AGI = new Asterisk::AGI;
        $AGI->exec("Set","CDR(userfield)=&IN_DID=$did");
	my (%output) = $AGI->ReadParse();
	my $config = {
		'_cti_obj' => $AGI,
		'_db' => 1
	};
	my %value_hash;
        my $default_values = {
		'timeout' => '5000',
		'timeout_count' => '2',
		'timeout_file' => '',
		'timeout_max' => '',
		'invalid_count' => '2',
		'invalid_file' => undef,
		'invalid_max' => undef
	};

	my $mem_obj = {
		'session_id' => $output{'uniqueid'},
		'callerid' => $output{'callerid'},
		'did' => $did
	};
		
	my $function = "__edas_welcome";
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
