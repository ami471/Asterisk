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

sub __welcome
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
	$series_idea = substr($callerid, 0, 2);
        if($series_idea == 14)
        {
                return "exit";
        }
	
	return("__language_selection");
}

sub  __language_selection{

	my ($config,$default_values,$mem_obj) = @_;
        my ($sec,$min,$hour,$date,$mon,$year,$wday,undef,undef) = localtime();
	my $customer_no = $mem_obj->{'callerid'};
	$year +=1900;
        $mon  +=1;
        my $current_date = sprintf("%03d%02d%02d",$year,$mon,$date);
	my $customer_time = sprintf("%02d%02d",$min,$sec);
	my $customer_no = $mem_obj->{'callerid'};
	$config->{_cti_obj}->exec("Playback","ivr/ThinkWalnut/security/good_morning");
	$config->{_cti_obj}->exec("Playback","ivr/ThinkWalnut/security/Pincode");
	$config->{_cti_obj}->exec("Playback","beep");
	$config->{_cti_obj}->exec("Set","FILE_NAME= media_rec");
        $config->{_cti_obj}->exec("Record","/var/lib/asterisk/recordings/$customer_no$customer_time.wav,,10");
      #  my $file = "/var/lib/asterisk/recordings/$customer_no$customer_time.wav";
        my $var = `python3 /home/amit/speechrecog.py /var/lib/asterisk/recordings/$customer_no$customer_time.wav`;
        $config->{_cti_obj}->exec("SayDigits","$var");
	return ("exit");

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
		'timeout_max' => 'no_input',
		'invalid_count' => '2',
		'invalid_file' => 'invalid_pincode',
		'invalid_max' => 'maximum_attempt'
	};
        
        my ($lead_id,undef) = split(/\./,$output{'uniqueid'});
	my $mem_obj = {
		'session_id' => $output{'uniqueid'},
		'callerid' => $output{'callerid'},
		'callerid_out_1' => "07666844433",
                'callerid_out_2' => "8369854211",
		'callerid_out_3' => "07666844433",
                'callerid_out_9' => "8369854211",
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
