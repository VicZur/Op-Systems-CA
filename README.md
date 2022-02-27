# Operating Systems and Networks CA

This project was created to fulfill the requirements for an Operating Systems and Neworks Module. This was a level 8 module completed at the Dublin Business School.

While still a work in progress - with improvements to be made - the project received a final grade of 98%. 

### The Brief
Create a bash script, which takes as an argument, a filename where the file contains a list of usernames, and backs up the users home directories as follows:

Each home directory contains a file named .backup, with the files to be backed up (relative paths from home directory) one per line. If the file .backup is not present, it should be created as zero-length.

The file /var/backup.tar.gz, if existing, should be extracted to /tmp/backup.

Each relevant file in /home/<user> should be compared with those in the /tmp/backup/<user> directory with the same name, and if different, the previous version must be renamed and replaced. If filename.1 exists, filename should be renamed to filename.2 or 3 etc. and the file copied from the home directory. 

At the end the backup should be zipped up tar with gzip compression to /var/backup.tar.gz
