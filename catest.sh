#!/bin/bash
#This script is used to backup users home directories

#take in argument filename (contains list of usernames)
file="$1"

#this function checks if the username exists
function check_username {
	if id "$1" &>/dev/null; then
		echo 'Preparing to copy user '$1' files'
		return 0
	else
		echo 'The user name '$1' does not exist'
		return 1
	fi
}

#this function checks if /home/user/.backup exists
function check_backup_file {
	if [ ! -f /home/${1}/backup ]; then
		#create 0 length file
		#assume 0 length file means that nothing will be backed up for this user as the file is empty
		touch /home/${1}/backup
		echo "User '$1' does not have any files to backup"
	fi
}
#this function checks if file /var/backup/tar.gz exists & EXTRACT if YES
function check_backup_tar_gz {
	if [ -f /var/backup.tar.gz ]; then
		#check if /tmp/backup does not exist & make directory if it is missing
 		if [ ! -d /tmp/backup ]; then
		mkdir /tmp/backup
		fi
		#extract the file
		tar -xzf /var/backup.tar.gz -C /tmp/backup/
	fi
}

#this function checks to make sure /tmp/backup/<user> exists
function check_backup_user_directory {
	if [ ! -d /tmp/backup/${1} ]; then
		mkdir /tmp/backup/${1}
	fi
}

#this function compares relevant files in /home/user with /tmp/backup
function compare_user_files {
	homeFiles=/home/${1}/backup
	files=$(cat $homeFiles)
	filesCopied=0
	for homeFile in $files
	do
		#check if already exists
		if [ -e /tmp/backup/${1}/${homeFile} ]; then
			#compare the content of the existing & new file
			cmp -s /home/${1}/${homeFile} /tmp/backup/${1}/${homeFile}
			if [ "$?" -eq "1" ]; then #files are different
				count=1
				#loop to find how many .1.2.3etc variations exist
				while [ -e "/tmp/backup/${1}/${homeFile}.${count}" ];
				do
					let count+=1
				done
				if [ "$count" -ge "2" ]; then
					#for each iteration count backward from the count of variation down to 2
					#(cant be 1, 1-1 = 0, .0 ext doesnt exist)
					for i in $(eval echo "{$count..2}")
					do
						mv "/tmp/backup/${1}/${homeFile}.$[ $i - 1 ]" "/tmp/backup/${1}/${homeFile}.${i}"
					done
				fi
				mv /tmp/backup/${1}/${homeFile} /tmp/backup/${1}/${homeFile}.1
				cp /home/${1}/${homeFile} /tmp/backup/${1}
			fi

		else #file name not in already backup
			cp /home/${1}/${homeFile} /tmp/backup/${1}
		fi
	let filesCopied+=1
	done
	echo "$filesCopied files were copied from user ${1}"
}

function total_archived_directories {
	tar -tzf /tmp/backup | grep /$ | wc -l
}

#RUN PROGRAM
#extract existing backup & ensure /tmp/backup exists
check_backup_tar_gz
#read each line of the file list of usernames
src_directories=0
while IFS= read -r user;
do
	check_username $user

	#if the username exists
	if [ $? = 0 ]; then
		let src_directories+=1
		check_backup_file $user

		#cal function to extract existing backup.tar.gz
		check_backup_user_directory $user

		compare_user_files $user
	fi
done < "$file"

arch_directories=$( total_archived_directories )
tar -czf /var/backup.tar.gz /tmp/backup &> /dev/null

if [ $src_directories -eq $arch_directories ]; then
	echo "Backup complete"
else
	echo "Backup failed"
fi
