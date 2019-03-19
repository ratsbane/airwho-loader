#!/usr/bin/perl

# This class represents the set of imported files that exists on disk, as well as an iterator over that set and
# some utility functions to create and manage the data sets extracted from those files.
# Although not currently implemented, this might be altered slightly to permit parallel loading of files through
# multiple instances - though that would require provisioning for multiple temp directories with different names. 
package FileSet;


sub new {
  my $class=shift;
  my $self={ current_file_index => undef,
             home => '/var/aircraft',
             all => [[]]   # initialize the file list with a blank one at the start
     };
  bless $self, $class;

  $self->all_files($min_date);    # reference to the list of files
  return $self;
  }


# Looks up  all file paths which are candidates for loading into history.  Pass in the first date that we could use or undef for all
sub all_files {
  my $self = shift;
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
        push @{$self->{'all'}}, $day;
        }
      }
    }
    #print "All files to process: ".join("\n", @{$self->{'all'}})."\n";
  }


# Given a date, sets the object instance's cursor to 
# two files before that, such that the file comparison will compare two files just before $date.
sub set_index_before {
  my $self = shift;
  my $date = shift;
  my $c=0;
  while ( $c < $#{$self->{'all'}} && (date_from_filename($self->{'all'}->[$c]) le $date) ) {$c++; }
  $self->{'current_file_index'} = $c;
  if (1 or $main::v) {print "set_index_before: \$date is $date and \$c is $c and the file is $self->{'all'}->[$c]\n";}
  }


# Increments file index and returns true if there is a next file; false otherwise
sub move_next {
  my $self = shift;
  return ($self->{'current_file_index'}++ < $#{$self->{'all'}});
  }


# Decrements file index and returns true if there is a previous file; false otherwise
sub move_prev {
  my $self = shift;
  return ($self->{'current_file_index'}-- > 0);
  }
 

# uses current_file_index to retrieve contents of array.  Returns ref to array of arrays of contents and scalar date string
sub get_file {
  my $self = shift;
 
  my @rows = ();
  my $date;
  my $filepath;
  if ($self->{'current_file_index'} > 0) {
    $filepath = $self->{all}->[$self->{'current_file_index'}];
    $date = date_from_filename($filepath);
    if ($self->_copy_and_unzip_file_into_temp($filepath)) {  # If there's a problem with the file and unzip returns error, don't try loading it. Return false.
      open my $f, '<', "$self->{'home'}/temp/MASTER.txt";
      read $f, my $buffer, -s "$self->{'home'}/temp/MASTER.txt";
      @rows = map { [ map {trim($_)} split /\s*,\s*/, $_ ] } split("\r\n", $buffer);
      close $f;
      }
    }
    return ( \@rows, $date );
  }
  
  
# Copies and unzips the file.  Returns true if successful
sub _copy_and_unzip_file_into_temp {
  my $self = shift;
  my $filename = shift;
  my $date = date_from_filename($filename);
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
 
  
# static method
sub date_from_filename {
  my $filename=shift;
  my ($y, $m, $d) = $filename =~ /(\d{4})-(\d{2})-(\d{2})/;
  if ($y && $m && $d) {return "$y-$m-$d";}
  else {return undef;}
  }

1;
