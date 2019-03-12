### Overview
In 2007 I was trying to research the history of some aircraft and I realized that, while current registration information was available from the FAA, history was not.  I briefly considered ways of time-travelling into the past to get this information, until I realized it would be much easier to time-travel into the future.

I set up a very small cron job to download weekly the list of registered US aircraft from the FAA.  After a few years, FAA changed to daily updates and I eventually rescheduled the cron job.

It has been running steadily since then and has downloaded over 1300 copies of the database over almost twelve years.  Recently I revisited this project.  Perhaps now is a good time to do something with this data.

### Loading the downloaded data into tables
There are seven different files in each of the downloaded .zip files.  Initially I would just like to do something with the "MASTER" file, which contains one row for each US registered aircraft.  I would like to construct two structures from this set of files
 -  a table of the current value for each active registration: owner, type, manufacturer, model, etc.;
 - a table containing details of all of the changes to each record - new records added, changes to exisiting records (new owner, etc.), and deleted registrations.

[Aircraft registration on FAA Website](http://www.faa.gov/licenses_certificates/aircraft_certification/aircraft_registry/releasable_aircraft_download/)

## load
I wrote a simple Perl program to unzip the current file and set up a MySQL "load data infile" statement.  This works fine for the current file. 
## load_history
To load the changes occuring between each of the 1300 files, we need something a little robust.  Over the last twelve years, there have been many anomolies involving these files - e.g., some of the files that we have downloaded have just been error messages; at several points the FAA has  altered the structure of the file by adding fields, etc.

I wrote a quick version of this last week and ran it on the 1300 files.  It loaded about 90 million change records into the MySQL table over several days, but as I looked at the data I realized that there were some problems - mostly duplicate records - caused mostly by dirty data.

I decided to rework load_history and make it more robust and also something that could be scheduled on a cron job - if it's called daily it will refresh the master_changes table with new information, but if it skips a few days or more, it will automatically do the right thing and ensure master_changes is updated and correct.

## download

Gets the file from the FAA.

Crontab

    15 7 *   *   *  /var/aircraft/bin/download

