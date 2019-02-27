#!/usr/bin/perl

# This class represents the set of imported files that exists on disk, as well as an iterator over that set and
# some utility functions to create and manage the data sets extracted from those files.
# Although not currently implemented, this might be altered slightly to permit parallel loading of files through
# multiple instances - though that would require provisioning for multiple temp directories with different names. 
package FileSet;


sub new {
  my $class=shift;
  my $self={ min_date => undef,
             current_file_path => undef,
             current_file_id => undef,
             home => '/var/aircraft'
     };
  bless $self, $class;

  $self->all_files($min_date);    # reference to the list of files
  return $self;
  }


# Looks up  all file paths which are candidates for loading into history.  Pass in the first date that we could use or undef for all
sub all_files {
  my $self = shift;
  my $min_date = shift;  # The minimum date that we will consider for inclusion in this list. Undef is ok; will return all.
  my $prev_day_size = undef;
  my $home = $self->{'home'};
  if ($main::v) {print "In all_files with \$min_date=$min_date.  Looking for files in $home\n";}
  my @years = grep {/\d{4}$/} <"$home/*">;

  foreach my $year(@years) {
    my @days = <"$year/*">;
    foreach my $day(@days) {
      
      # Many files are repeats of previous day, because the FAA hadn't updated the file when we downloaded it.
      # This uses the file's size to exclude those duplicates.
      # Also, 30mb seems like a reasonable estimate to exclude the bulk of the remaining problem files
      my $s = -s $day;
      if ($s != $prev_day_size and $s>30000000) {
        $prev_day_size = $s;
        push @all, $day;
        }
      }
    }
  $self->{'all'} = [@all];
  }


# returns 1) a reference to the array-of-arrays that's the data from the first file in the list and 2) a string containing the date, e.g., 2019-02-26
sub get_first {
  my $self = shift;
  $self->{'current_file_id'} = 0;
  return $self->_load_file();
  }


# iterates through the list of files.  returns data from file and date of file.  At the end of the list, returns nothing (false)
sub get_next {
  my $self = shift;
  if ($self->{'current_file_id'} < $#{$self->{'all'}}) {
    $self->{'current_file_id'}++;
    return $self->_load_file();   # returns an array of two things: ref to dataset and scalar date string
    }
  else {return undef;}
  }


# uses current_file_id to retrieve contents of array.  Returns ref to array of arrays of contents and scalar date string
sub _load_file {
  my $self = shift;
  my @rows;
  my $filepath = $self->{all}->['current_file_id'];
  my $home = $self->{'home'};
  my ($date) = date_from_filename($filepath);
  print STDOUT "in _load_file with \$filepath is $filepath and \$date is $date\n";
  if ($self->_copy_and_unzip_file_into_temp($filepath)) {  # If there's a problem with the file and unzip returns error, don't try loading it. Return false.
    open my $f, '<', "$home/temp/MASTER.txt";
    read $f, my $buffer, -s $filepath;
    my @rows = split("\r\n", $buffer);
    @rows = map { [ map {trim($_)} split /\s*,\s*/, $_ ] } @rows;
    close $f;
    }
  return ( \@rows, $date );
  }
  
  
# Copies and unzips the file.  Returns true if successful
sub _copy_and_unzip_file_into_temp {
  my $self = shift;
  my $filename = shift;
  my ($date) = date_from_filename($filename);
  my $home = $self->{'home'};

  if ($main::v) {print "copy_and_unzip_file_into_temp: Loading $filename into temp\n";}

  # Ensure temp dir exists
  if (-e "$home/temp") {`rm -r $home/temp/*`;}
  else {mkdir "$home/temp";}
 
  `cp $filename $home/temp/$date.zip`;

  `unzip -qq $home/temp/$date.zip -d $home/temp > /dev/null 2>&1`;
  if (-e "$home/temp/MASTER") {rename "$home/temp/MASTER", "$home/temp/MASTER.txt";}
  return -e "$home/temp/MASTER.txt";
  }

  
# static method - call on the package, not the instance.
sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
 
  
# static method - call on the package, not the instance.
sub date_from_filename {
  my $filename=shift;
  my ($y, $m, $d) = $filename =~ /(\d{4})-(\d{2})-(\d{2})/;
  return ("$y-$m-$d", $y, $m, $d);
  }

1;
