require 'fileutils'
require 'find'

# This script loads a file containing on each line the absolute path of a 
# folder to be backed up. This works on Unix-type OS's as well as Windows.
# Simply put all of the folders and files that you want to backup into backup_folders.txt
# (one per line) and change BACKUP_PATH to point to the location to which you want to save the files.

FOLDER_LIST_PATH = "backup_folders.txt"
BACKUP_PATH = "J:/selective_backup"
EMPTY = 2 # If a directory has only two links, it is empty.

# Load the file that contains the folders that we want to backup.
def backup_folders(backup_path = BACKUP_PATH) 
  if File.exists?(FOLDER_LIST_PATH)
    File.open(FOLDER_LIST_PATH, 'r').each_line do |line|
      path = line.chomp
      
      # Don't copy empty or non-existent directories.
      next if !File.exists?(path)
      next if File.directory?(path) && Dir.entries(path).size == EMPTY
      
      # Recursively copy files and folders using Find.
      recursive_backup(path, backup_path)
    end
    return true
  else
    return false        
  end
end

# Recursively copy the files and folders into the correct backup path.
# If the newer file is in the backup path, don't copy over the file.
def recursive_backup(src_path, dest_path)
    # If the path does not exist, it will first be created.
    FileUtils.makedirs([dest_path])
    Find.find(src_path) do |path|
      if File.file?(path)
        # If this file doesn't exist in the dest_path or is newer 
        # than the same file in the dest path, copy it over.
        dest_file = dest_path + "/" + File.basename(path)
        if !File.exists?(dest_file) || File.mtime(dest_file) < File.mtime(path)
          FileUtils.copy(path, dest_file)
        end
      else
        next if Dir.entries(path).size == EMPTY
        dest_path = dest_path + "/" + File.basename(path)
        FileUtils.makedirs([dest_path])
      end
    end
end

print "Enter filepath for backup or \"d\" for default path: "
filepath = gets.chomp
puts "Starting backup"

result = false
if filepath == 'd'
result = backup_folders()
else
result = backup_folders(filepath)
end

if result
  puts "Backup successful."
else
  puts "Backup failed."
end
