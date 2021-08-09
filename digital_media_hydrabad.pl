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
use HTTP::Request::Common;
use LWP::UserAgent;
use LWP::Simple;

sub __welcome
{
  	my ($config,$default_values,$mem_obj) = @_;
	my $weekday;
        my $day_is;
	my $zone;
	my $time_now;
	my $media_channel;
        my $media_vehicle;
        my $lead_source;
	my $series_idea;
        my $location;
        my $pincode;
	my $contact_1;
        my $state;
        my $zone;
        my $content;
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
	$mem_obj->{'current_time'}  = $current_time;
	$mem_obj->{'current_date'}  = $current_date;
	$mem_obj->{'day_is'}        = $day_is;
	$mem_obj->{'weekday'}       = $weekday;
        if ($time_display >= '210000' && $time_display < '240000')
	{
		$time_now = "NIGHT";
	}
	if ($time_display >= '050000' && $time_display < '120000')
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
	if ($time_display >= '000000' && $time_display < '090000')
        {
                $time_now = "NIGHT";
                
	}
         if($mem_obj->{'did'} == 8691)
         {
                
                $mem_obj->{'did_mobile'} = '9112207702';

         }
	$mem_obj->{'time_now'} =  $time_now;
	 my $mobileno_length = length($mem_obj->{'callerid'});
        if ($mobileno_length > 10)
        {
                my $n = 2;
                $mem_obj->{'callerid'} = substr( "$mem_obj->{'callerid'}",$n);

        }
        my $callerid = $mem_obj->{'callerid'};
	$content='07569202073';
     #   $content='08369854211';
        print($content);
        $mem_obj->{'contact_1'} = $content;
        my $tablename = 'digitalmedia_hydrabad';
        my $dbh = DBI->connect("dbi:mysql:database=asterisk;host=localhost","root","mys\@r0ja");
        my $count =0;
        my $header = 'fsd';
        my $query = "INSERT INTO $tablename (mobile_no,date,time,day,Time_Session,campaign,weekday,media_vehicle,media_channel,agent_number,did) VALUES('$callerid','$current_date','$current_time','$weekday','$time_now','Online_house_connect','$day_is','Online','Online Gold Loan','$contact_1','$mem_obj->{'did_mobile'}')";
        my $sth = $dbh->prepare($query) ;
        my $ret =$sth->execute();
        $dbh->disconnect();

	$series_idea = substr($callerid, 0, 2);
        if($series_idea == 14)
        {
                return "exit";
        }
	return("__dialagent");


}

sub __dialagent {

       my ($config,$default_values,$mem_obj) = @_;
       my $customer_no = $mem_obj->{'callerid'};
       $config->{_cti_obj}->exec("Playback","ivr/ThinkWalnut/shadi_Final/eng/connecting");
       my $dial_group = $mem_obj->{'dial_group'};
       my $dial_out = $mem_obj->{'callerid_out_9'};

       my $dial_channel = $mem_obj->{'dial_channel'};

       my $timeout = $mem_obj->{'dial_timeout'};

       my $filename = "gss-".$mem_obj->{callerid}."-".$mem_obj->{session_id};

      $config->{_cti_obj}->exec("Monitor","wav,$filename,m");
  
      my $out_no = $mem_obj->{'contact_1'};
      my $dial_string =$dial_channel."/".$dial_group."/".$out_no;

       my $status = $config->{_cti_obj}->exec("Dial","$dial_string,$timeout,gm[gss]");

       my $call_status = $config->{_cti_obj}->get_variable("DIALSTATUS");

       if ($call_status eq "ANSWER") {

              return "exit";
	}
      if ($call_status eq "BUSY") {
	 my $tablename = 'digitalmedia_hydrabad';
         my $value = 1;
         my $dbh = DBI->connect("dbi:mysql:database=asterisk;host=localhost","root","mys\@r0ja");
         my $query = "update $tablename set status ='BUSY' where mobile_no = '$customer_no' order by id desc limit 1";
         my $sth = $dbh->prepare($query);
         $sth->execute();
         if ($sth->rows()) {

                $value =  0;
          }
          $sth->finish();
          $dbh->disconnect();
	  # $config->{_cti_obj}->exec("Playback","busy");
          return "exit";
      }
         
      if ($call_status eq "NOANSWER") {
      
        my $tablename = 'digitalmedia_hydrabad';
        my $value = 1;
        my $dbh = DBI->connect("dbi:mysql:database=asterisk;host=localhost","root","mys\@r0ja");
        my $query = "update $tablename set status ='NOANSWER' where mobile_no = '$customer_no' order by id desc limit 1";
        my $sth = $dbh->prepare($query);
        $sth->execute();
        if ($sth->rows()) {

                $value =  0;
         }
         $sth->finish();
         $dbh->disconnect();
        # $config->{_cti_obj}->exec("Playback","busy");
       	return "exit";
      }

       $config->{_cti_obj}->exec("StopMonitor","");
       return "exit";

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
        my $file_name = "/uc/config/ini/shadi.conf";
	read_ini_file($file_name,\%value_hash);
        my $default_values = {
		'timeout' => '5000',
		'timeout_count' => '2',
		'timeout_file' => 'no_input',
		'timeout_max' => 'no_input_max',
		'invalid_count' => '2',
		'invalid_file' => 'invalid_pincode',
		'invalid_max' => 'maximum_attempt'
	};
        
        my ($lead_id,undef) = split(/\./,$output{'uniqueid'});
	my $mem_obj = {
		'session_id' => $output{'uniqueid'},
		'callerid' => $output{'callerid'},
		'dial_group' => "$value_hash{shadi}->{dial_group}",
		'dial_channel' => "$value_hash{shadi}->{dial_channel}",
		'dial_timeout' => "$value_hash{shadi}->{dial_timeout}",
		'did' => $did
	};
		
	my $function = "__welcome";
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
