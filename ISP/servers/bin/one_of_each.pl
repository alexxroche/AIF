#!/usr/bin/perl
# a librarian for one_of_each.pl ver 0.1 20100614 alexx at alexx dot net
# ver 0.2 20110606 alexx at alexx dot net NTS we need to check that the db isn't stale before we trust it
use strict "vars";
#use strict "refs";
no strict "refs";
use strict "subs";

# if we recurse and don't find ONE directory with a DB then SAY SO!
# if we replace EVERY file in a directory (except our DB file) with a sym-link, then report it or wipe that dir as pointless
# 	(checking that we don't have any directories in this duplicate directory)
#
# NTS BEFORE we remove a file CHECK THAT THE FILE THAT WE ARE LINKING TO EXISTS and is more than 1000 bytes

# NOTE MUST first check that the user running this script has write access to the .db file!
# NTS 20090427 the index.html kept changing but we didn't remove the old hash from the .db
#	not quite sure what to do with this info

# cleans up the back-ups once we are happy that this script has not munged everything
if($ARGV[0] eq 'delete_those_files_that_the_debug_created'){ system("find . -name \"\*ooe_arch\" -exec rm \{\} \\;"); print "Cleaner\n"; exit; }
#if($ARGV[0] eq 'delete_those_files_that_the_debug_created'){ print `find . -name "*ooe_arch" -exec rm {} \;`; print "Cleaner\n"; exit; }

use DB_File;
my %opt;
$|=1;
$opt{START} = `date`; chop($opt{START});
my $hash = 'MD5';

sub help {
	print "Usage: $0 [-r [-b]][-w][-h][-s][-pwd \$path][-e \$exception]
	-w causes the duplicates to be wiped (deleted)
	-v verbosely reports previous duplicates
	-r recuses\n\t-b builds when recursing
	-a absolute paths (the default is relative)
	-s this forces a slower check as it recurses
	-d increments the debug level (this also backs ups files, so if you are not sure..)\n";
	#print "\t-hl hard link files (symbolic links are the default)\n";
	print " This will check that all the files in a directory are unique\n you can except some file extensions such as html\n";
	pwd() unless($opt{BASE_PATH});
	print "The default behaviour is just to build for the present working directory '$opt{BASE_PATH}' (where you are)\n";
	print "Copyright 2010 Cahiravahilla publications\n"; 
exit(0);
}
my @exceptions = ('swp$','db$','pl$','^.$','^..$');

#my $script_pwd;
#BEGIN { 
#        $script_pwd = `readlink -mn $ENV{_}`;
#        $script_pwd=~s|/([^/]*)$||;
#        chomp($script_pwd);
#}
#use lib "$script_pwd";

sub pwd{
        my $base_path = shift;
        my $your_pwd = `echo \$PWD`; chomp($your_pwd);
        $base_path = $your_pwd unless $base_path;
	$base_path .= '/' unless $base_path=~m|/$|;
	$opt{BASE_PATH} = $base_path;
}

# we can set up fixed groups of behaviour using links to the same file
my $fn = $0; $fn=~s/^.*\///;
if($fn eq 'ooe'){ push @ARGV, '-b','-w','-r','-v','-s'; open(STDOUT,">>.ooe.log"); $opt{print_tail}++; }
# just ln -s /usr/local/bin/one_of_each.pl /usr/local/bin/ooe 

for(my $args=0;$args<=(@ARGV -1);$args++){
        if ($ARGV[$args]=~m/^-+h/i){ &help; }
        elsif ($ARGV[$args] eq '-d'){ $opt{D}++; } #GLOBAL DEBUG
        elsif ($ARGV[$args] eq '-v'){ $opt{verbose}++;}
        elsif ($ARGV[$args] eq '-w'){ $opt{wipe}++;}
        elsif ($ARGV[$args] eq '-s'){ $opt{slow}++;}
        elsif ($ARGV[$args] eq '-a'){ $opt{absolute}++;}
        elsif ($ARGV[$args] eq '-h'){ $opt{hard_link}++;}
        elsif ($ARGV[$args] eq '-r'){ $opt{r}++;} #recurse
        elsif ($ARGV[$args] eq '-b'){ $opt{build}++;}
        elsif ($ARGV[$args]=~m/-+r.*/){ $opt{r}++;} #recurse
        elsif ($ARGV[$args]=~m/-+path(.+)/){ $opt{BASE_PATH} = $1; }
        elsif ($ARGV[$args]=~m/-+path/){ $args++; $opt{BASE_PATH} = $ARGV[$args]; }
        elsif ($ARGV[$args]=~m/-+dir(.+)/){ $opt{BASE_PATH} = $1; }
        elsif ($ARGV[$args]=~m/-+dir/){ $args++; $opt{BASE_PATH} = $ARGV[$args]; }
        elsif ($ARGV[$args]=~m/-+pwd(.+)/){ $opt{BASE_PATH} = $1; }
        elsif ($ARGV[$args]=~m/-+pwd/){ $args++; $opt{BASE_PATH} = $ARGV[$args]; }
        #elsif ($ARGV[$args]=~m/-+e(.+)/){ push @{ $opt{except} }, $1; }
        #elsif ($ARGV[$args]=~m/-+e/){ $args++; push @{ $opt{except} }, $ARGV[$args] }
        elsif ($ARGV[$args]=~m/-+e(.+)/){ push @exceptions, $1; }
        elsif ($ARGV[$args]=~m/-+e/){ $args++; push @exceptions, $ARGV[$args] }
        else{ print "what is this $ARGV[$args] you talk of?\n"; &help; }
}

pwd() unless $opt{BASE_PATH};
$opt{BASE_PATH} .= '/' unless $opt{BASE_PATH}=~m|/$|;

sub create_hash {
   my $dir = shift; chomp($dir);
   my $dbh = shift;
   my %dbhash;
   #my $dbfile = "$dir$path/.${path}.db";
   my $dbfile = $dir;
   print "dir = $dbfile\n" if $opt{D}>=1 && $opt{verbose}>=1;
   chomp($dbfile);
   $dbfile=~s|/$||; #strip the last / if there is one
   $dbfile=~s|^.*/(.+)|$1|;
   $dbfile = '.' . $dbfile unless $dbfile=~m/^\./;
   $dbfile .= '.db' unless $dbfile=~m/\.db$/;
   print "dbfile name = $dbfile\n" if $opt{D}>=1 && $opt{verbose}>=1;
   $dir=~s|^(.*)/.+|$1| if $dir=~m/$dbfile$/;
   print "dir = $dbfile\n" if $opt{D}>=1 && $opt{verbose}>=1;


   #open DB (create it if it does not exist)
   # If we have renamed a directory then there may be a "stale" .$dir_name.db file... we should see 
   #  if it is one of ours and just rename it if it is
   my $db;
   my $remove_db="$dir/$dbfile";
   $remove_db='' if (-f "$remove_db");
   unless($dbh->{nodb}){$db = tie %dbhash,'DB_File',"$dir/$dbfile",O_RDWR|O_CREAT,0644,$DB_HASH;}
   print "opening $dir\n" if $opt{D}>=1 && $opt{verbose}>=1;
   opendir DIR,$dir;
   my @files = readdir DIR;
   closedir(DIR);
   print "closing $dir\n" if $opt{D}>=2 && $opt{verbose}>=1;
   FILE: foreach my $file (@files){
        # exceptions
        foreach my $except (@exceptions){
                #print "checking $except\n" if $opt{D}>=5 && $opt{verbose}>=1;
                next FILE if($file=~m/$except/);
                #print "$file does not match $except\n" if $opt{D}>=5 && $opt{verbose}>=1;
        }
        next FILE if(-d "$dir/$file");
        next FILE if(-l "$dir/$file"); #skip symlinks
                #do an MD5 sum of the file
                #NTS we should be able to skip files alreadyin the hash(option)
                my $mdfive;
		if($hash eq 'MD5'){
			my $escaped_file = $file;
			$escaped_file=~s/"/\\"/g;
                	$mdfive = `md5sum "$dir/$escaped_file"`; $mdfive=~s/(\w+)\s*.*$/$1/;
		}else{
			die "I don't do $hash - just say no!";
		}
                chomp($mdfive);
		$remove_db='';
                ##my $term_name = md5_base64($term->{text});
                #my $md5 = Digest::MD5->new;
                #open( FILE, "$dir/$file");
                #binmode(FILE);
                #$md5->addfile(*FILE);
                #my $mdfive = $md5->digest;
		$opt{NOW} = `date`; chop($opt{NOW});
                if(!$dbhash{$mdfive}){
                        $dbhash{$mdfive} = $file;
                        $dbhash{"$mdfive:date"} = $opt{NOW};
                        print STDERR "." if $opt{verbose}==1;
                }elsif($dbhash{$mdfive} ne $file){
                        # we already have this copy so...
                        print "$file is a duplicate of $dbhash{$mdfive} [$mdfive]" if $opt{verbose}>=1;
                        if($opt{wipe}){ #wipe/delete duplicates #if $opt{r} we should probably default to $opt{wipe}
				$file = '/' . $file unless $dir=~m|/$|;
				if($opt{verbose}>=1){
					my @stats = stat("$dir$file");
					$opt{SpaceSaved} += $stats[7];
				}
                                unlink("$dir$file");
                                print " removed $dir$file\n" if $opt{verbose}>=1;
                        }else{
                        	print "\n" if $opt{verbose}>=1;
			}
                        #make a record of how many times we have removed this
                        #duplicate and when
                        $dbhash{"$mdfive:d"}++;
                        $dbhash{"$mdfive:d:date"} = $opt{NOW};
                }
   }
   #NTS To do: this can leave crap in the db that is no longer needed.
   # would need to loop through the HASH to check files that we no longer have.
   #NTS 20090427 or ones we have that have changed! (see any_hash_check.pl)
   #close DB
   if($dbh){
	delete($dbh->{nodb});
	undef %{ $dbh };
	%{ $dbh } = %dbhash;
   }else{
   	$db->sync();
   	undef $db;
   	untie %dbhash;
   }
   unlink $remove_db if $remove_db;
   print "Done that\n" if !$opt{slow} && $opt{verbose}>=1;
}

sub path_sort {
	# you can change this to alter the recursive behaviour, though the default, (obviously) works for me
                #if ($a=~m/^\d/){
                #       ( $a <=> $b )
                #}else{
                        ( $a cmp $b )
                #}
}

sub compare_hash_db{
   my $oldDB = shift;
   my $newDB = shift;
   #my $this_dir = shift;
   my %old_dbhash;
   my %new_dbhash;
   my $new_dir = $newDB;
   $new_dir=~s|/\.[^/]+\.db$||;

   #open DB
   my $old_db_sth;
   my $new_db_sth;
   if(-f "$oldDB"){$old_db_sth=tie %old_dbhash,'DB_File',"$oldDB",O_RDWR,0644,$DB_HASH;}
   if(-f "$oldDB"){$new_db_sth=tie %new_dbhash,'DB_File',"$newDB",O_RDWR,0644,$DB_HASH;}
   if($old_db_sth && $new_db_sth){ print "comparing $oldDB with $newDB\n" if $opt{D}>=1; $opt{dbopen}++;}
   else{  #we have to create %new_dbhash with the details of the files in $this_dir
	print "creating hashes for $new_dir\n" if $opt{D}>=1 && $opt{verbose}>=1;
	$new_dbhash{nodb}++;
	create_hash($newDB,\%new_dbhash) unless $opt{D}>=2;
	return if $opt{D}>=2;
	# there is a bug in here somewhere that is activated by BUG1 (you can search for it)
	# If you have -d ($opt{D}) and recursive then it creates a backup
	# (which is fine) but THEN compare_hash_db compares the backup and creates another backup
	# which should  not happen because the hash is created before we loop through.
   }
   unless(keys %new_dbhash >=1){ print "No new files found in $newDB\n" if $opt{verbose}>=5; return; }
   
   NEWFILE: foreach my $hash (keys %new_dbhash){
	#print "$hash\n" if $hash=~m/.+:d.+/ && $opt{D};
	next NEWFILE if $hash=~m/.+:d/; # date entry
	foreach my $except (@exceptions){
                #warn "checking for matching $except\n" if $opt{D}>=1;
                #print "checking for matching $new_dbhash{$hash} eq /$except/\n" if $opt{D}>=1;
                next NEWFILE if($new_dbhash{$hash}=~m/$except/);
                if($new_dbhash{$hash}=~m/$except/){
                	next NEWFILE if($new_dbhash{$hash}=~m/$except/);
               		#warn "$hash DOES match $except\n" if $opt{D}>=1;
		}
                #print "$hash does not match $except\n" if $opt{D}>=1;
        }
	#my $this_file = $this_dir;
	if($old_dbhash{$hash} || $opt{db}{dupes}{$hash}){

		my $rel_path;
		if($old_dbhash{$hash}){
			$rel_path = $oldDB;
			$rel_path =~s/^$opt{BASE_PATH}// unless $opt{absolute};
			$rel_path =~s|/\.[^/]+\.db$||;
			$rel_path.= '/'. $old_dbhash{$hash};
			print "old_dbhash matched $hash ($old_dbhash{$hash}) <$oldDB>\n" if $opt{D}>=1 && $opt{verbose}>=2;
			my($dir,$file);
                	$file = $old_dbhash{$hash};
                	$dir = $oldDB;
                	$dir =~s|/\..+\.db$||;
                	$opt{db}{dupes}{$hash}{db} = $oldDB;
                	$opt{db}{dupes}{$hash}{dir} = $dir;
                	$opt{db}{dupes}{$hash}{file} = $file;
                	print "PUSHING $hash ($dir / $file) to OLD SEEN db $oldDB\n" if $opt{D}>=1 && $opt{verbose}>=3;
                	print "$hash ($new_dbhash{$hash}) IS in $oldDB ($old_dbhash{$hash})\n" if $opt{D}>=1;
		}
		if($opt{db}{dupes}{$hash}){
			print "opt db dupes  matched $hash ($opt{db}{dupes}{$hash}{file}) <$opt{db}{dupes}{$hash}{dir}>\n" if $opt{D}>=1 && $opt{verbose}>=1;
			$rel_path = $opt{db}{dupes}{$hash}{dir};
			$rel_path=~s/^$opt{BASE_PATH}// unless $opt{absolute};
			$rel_path .= '/'.$opt{db}{dupes}{$hash}{file} if $rel_path;
		}
         	#next NEWFILE if(-l "$new_dir/$new_dbhash{$hash}"); #skip symlinks
         	if(-l "$new_dir/$new_dbhash{$hash}"){ #skip symlinks
		  print "$new_dir / $new_dbhash{$hash} is a symLINK [$hash]\n" if $opt{D}>=1 && $opt{verbose}>=2;
		  next NEWFILE;
		}else{
		  print "$new_dir / $new_dbhash{$hash} is NOT a LINK [$hash]\n" if $opt{D}>=1 && $opt{verbose}>=2;
		}
			
		
		# cruch time! what do we do with the drunken sailor? (and this duplicate file?)
		# probably want to replace it with a symbolic link back to the original
		$opt{db}{dupes}{$hash}{count}++;
		#$opt{db}{dupes}{$hash} ? my $original = $opt{db}{dupes}{$hash} : my $original = $oldDB;
		my $original;
		#$opt{db}{dupes}{$hash} ? $original = $opt{db}{dupes}{$hash}{file} : $original = $oldDB;
		#$original = $opt{db}{dupes}{$hash} || $original = $oldDB;
		$original = $opt{db}{dupes}{$hash}{file};
		$original = $oldDB unless $original;
		my $new_file = $new_dbhash{$hash};
		print "$new_file hash matches $original ($opt{db}{dupes}{$hash}{dir} DIR / FILE $opt{db}{dupes}{$hash}{file}) " .'['. $hash .']'."\n" if $opt{D}>=1;
		# we should try a different hash e.g md5sum => sha256, sha256 => md5sum
		# just to be sure (and we could collect collision examples! )
		if("$opt{db}{dupes}{$hash}{dir}/$original" eq "$new_dir/$new_file"){ # this is the problem with unsorted hash keys
			print "$new_file IS $original file [$hash]\n" if $opt{D}>=1;
			next NEWFILE;
		}else{
			print "$opt{db}{dupes}{$hash}{dir} = $new_dir [$hash]\n" if $opt{D}>=1;
			print "$original = $new_file [$hash]\n" if $opt{D}>=1;
		}
         	next NEWFILE if(-l "$new_dir/$new_file"); #skip symlinks
		unless ($rel_path){
			warn "ERR: NO relative path! ($rel_path)";
			next NEWFILE;
		}
		#unless($this_file){ $this_file = $newDB; }
		my $this_file = $newDB;
		warn "PRE-TF: $this_file [$hash]" if $opt{D}>=3;
			
		$this_file=~s/^$opt{BASE_PATH}// unless $opt{absolute};
		$this_file =~s|/\.[^/]+\.db$||;
		$this_file .= '/'. $new_dbhash{$hash};
		#  IF $rel_path and $this_file start with the same then replace each level with ../
		print "RP: $rel_path [$hash]\n" if $opt{verbose}>=2;
		
		next NEWFILE if $this_file=~m|\..+\.ooe_arch|;
		unless($opt{absolute}){
		
			my @rel = split/\//, $rel_path;
			my @this_path = split/\//, $this_file;
			my $sim_link;
			print "RE-paths: $rel_path TP-path: $this_file\n" if $opt{verbose}>=3;
			$rel_path = '';
			# if the depth of $rel_path and $this_path are not the same then we are stripping one two many ../
			# NTS YOU ARE HERE: THIS IS A BUG ... that I think I have fixed
			my $shrink = 1; #remove levels if they match
			my $shrunk = 0; #how many we matched
			print "RE-depth: " . @rel , " TP-depth: " . @this_path . " [$hash]\n" if $opt{verbose}>=3;
			my $path_inbalance = @this_path - @rel;
			#my $path_inbalance = @rel - @this_path;
			STRIP: foreach my $level (@rel){
				next STRIP unless $level;
				my $shift_bin = shift @this_path;
				#if($shrink==1 && "$level" eq shift @this_path){
				if($shrink==1 && "$level" eq $shift_bin){
					$shrunk++;
					next STRIP;
				}
				elsif("$level" && $shift_bin){
					$shrink='';
					$sim_link .= '../';
				}
				$rel_path .= "/$level";
				
			}
			warn $path_inbalance if $opt{verbose}>=3;
			if($path_inbalance >= 2){
				for(my $i=1;$i<$path_inbalance;$i++){
					$sim_link .= '../';
					warn "going up\n" if $opt{verbose}>=3;
				}
			}elsif($path_inbalance <= 0){
				print "SL: $sim_link ; RP: $rel_path [$hash]\n" if $opt{verbose}>=3;
				#for (my $i=$path_inbalance;$i<0;$i++){
					$sim_link =~s|^\.\.\/||;
					warn "going down\n" if $opt{verbose}>=3;
				#}
				print "SL: $sim_link ; RP: $rel_path [$hash]\n" if $opt{verbose}>=3;
			}
			print "SL: $sim_link ; RP: $rel_path [$hash]\n" if $opt{D} && $opt{verbose}>=1;
			#$sim_link =~s|/\.\./$||; # we strip one level because we also have the fILE name!
			#$sim_link =~s|/\.\./$|| if $shrunk; #why? I think this might be related to the next DIRTY HACK!
			print "SHRUNK!\n" if $shrunk && $opt{D} && $opt{verbose}>=1;
			$rel_path=~s|^/||;
			$rel_path = $sim_link . $rel_path;
			print "SL: $sim_link ; RP: $rel_path [$hash]\n" if $opt{D} && $opt{verbose}>=1;
		}
		if($opt{D}){ 
			my $that_file = $this_file; 
			$that_file=~s|/([^/]+)$|/.$1.ooe_arch|; #N.B. this is used to prevent us "arch"-ing arched files
					# this is only really for testing
			my $mvc;
			while(-f "$that_file"){ my $c = $mvc; $c++; $that_file =~s/_?$mvc\.([^.]+)$/_$c\.$1/; $mvc = $c;}
			print "moving $this_file to $that_file [$hash]\n" if $opt{verbose}>=2;
			rename($this_file,$that_file) unless $opt{D}>=2; 
			# now that $this_file has "gone" we HAVE to remove it from the DB
			if($new_dbhash{$hash} && $opt{D}<=1){
				delete($new_dbhash{$hash});
				delete($new_dbhash{"$hash:d"}) if $new_dbhash{"$hash:d"}; #number of duplicates
				delete($new_dbhash{"$hash:date"}) if $new_dbhash{"$hash:date"}; # when
			}else{
				print qq |[$hash] trying to remove $new_dbhash{$hash}\n| if $opt{verbose}>=1;
				print qq |[$hash] trying to remove $new_dbhash{"$hash:d"}\n| if $opt{verbose}>=1;
				print qq |[$hash] trying to remove $new_dbhash{"$hash:date"}\n| if $opt{verbose}>=1;
			}
		}else{
			if($new_dbhash{$hash}){
                                delete($new_dbhash{$hash});
                                delete($new_dbhash{"$hash:d"}) if $new_dbhash{"$hash:d"}; #number of duplicates
                                delete($new_dbhash{"$hash:date"}) if $new_dbhash{"$hash:date"}; # when
                        }else{  
                                print qq |[$hash] trying to wipe $new_dbhash{$hash}\n| if $opt{verbose}>=1;
                                print qq |[$hash] trying to wipe $new_dbhash{"$hash:d"}\n| if $opt{verbose}>=1;
                                print qq |[$hash] trying to wipe $new_dbhash{"$hash:date"}\n| if $opt{verbose}>=1;
                        }
			if($opt{verbose}>=1){
				my @stats = stat($this_file);
				$opt{SpaceSaved} += $stats[7];
			}
			unlink($this_file) unless $opt{D}>=1;
		}
		print "ln -s $rel_path $this_file #[$hash]\n" if $opt{verbose}>=1;
		$rel_path=~s/"/\\"/g; $this_file=~s/"/\\"/g;
		system("ln -s \"$rel_path\" \"$this_file\"") unless $opt{D}>=2;
	
	}else{
		my($dir,$file);
		$file = $new_dbhash{$hash};
		$dir = $newDB;
		$dir =~s|/\..+\.db$||;
		$opt{db}{dupes}{$hash}{db} = $newDB;
		$opt{db}{dupes}{$hash}{dir} = $dir;
		$opt{db}{dupes}{$hash}{file} = $file;
		print "adding $hash ($dir / $file) to the SEEN db $newDB\n" if $opt{D}>=1 && $opt{verbose}>=2;
		print "$hash ($new_dbhash{$hash}) is not in $oldDB ($old_dbhash{$hash})\n" if $opt{D}>=1;
	}
   }
   if($opt{dbopen}){
	if($new_db_sth){
   	   $new_db_sth->sync();
   	   undef($new_db_sth);
   	   untie(%new_dbhash);
	}
	if($old_db_sth){
   	   undef($old_db_sth);
   	   untie(%old_dbhash);
	}
   }
}

sub inspect_hash_db{
   my $db = shift;
   my $hash = shift;
	# we have two modes: fast (just compares the present and the previous HASH db AND known duplicates) *cough* not quite anymore
	#			we would need a "ludicrous speed" to do that (and save on the RAM and speed)
	#		     slow (compares this HASH db with EACH of the previous ones AND 
	#			  creates hashes for files that are not in any DB and holds them in memory $opt{db}{dupes}{$hash})
   if($opt{slow}){
	print "going slow: $db\n" if $opt{D}>=1 && $opt{verbose}>=1;
	if($opt{db}{last}[0]){
		#foreach my $oldDB (@{$opt{db}{last}}){
		# we should do this foreach, but *cough* we are just cheating and sticking the whole lot into RAM
		# If we put back the foreach it works (unless you are running in debug mode, then it does something odd)
		# BUG1
		my $oldDB = shift @{$opt{db}{last}};
		compare_hash_db($oldDB,$db);
		#}
	}
	push @{$opt{db}{last}},$db;
   }else{
	if($opt{db}{last}){
		compare_hash_db($opt{db}{last},$db);
	}
	$opt{db}{last} = $db;
   }
}

sub recurse_path {
        my $dir = shift;
        my $hash = shift;
        # collect paths and stuff into
        if($dir!~m|/$|){ $dir .= '/'; }
        return("No files in $dir\n") unless system("ls $dir* 2>\&1 1>/dev/null") == 0;
        my @paths = `ls $dir|sed 's/ /\\ /g' 2>/dev/null`; #NTS should we escape " and ' while we are at it?
        RAFFPP: foreach my $path (sort path_sort @paths){
                chomp($path);
		if (-d "$dir$path"){
			#  we skip empty directories
			print "Thinking about $dir$path/*\n" if $opt{D}>=2 && $opt{verbose}>=1;
                	next RAFFPP unless system("ls $dir$path/* 2>/dev/null 1>/dev/null") == 0;
			print "looking at $dir$path/*\n" if $opt{D}>=2 && $opt{verbose}>=1;
                	my $db = "$dir$path/.${path}.db";
                	print "DB: $db - " if $opt{D}>=1 && $opt{verbose}>=1;
                	print "PATH: ($dir)$path\n" if $opt{D}>=2;
                	if(!-f "$db" && $opt{build} ){ print "no $db so creating.....\n" if $opt{D}>1 && $opt{verbose}>=1; &create_hash($dir,$hash); }
                	if($opt{build}){ &compare_hash_db($opt{db}{last},$db); }
                	&inspect_hash_db("$db",$hash) if(-f "$db" || $opt{slow});
			recurse_path("$dir$path",$hash) if (-d "$dir$path");
                	next RAFFPP unless (-f "$db");
		}
        }
}

if($opt{r}){
	my $output = recurse_path($opt{BASE_PATH},$hash);
	print $output if $opt{D}>=1;
	my $nice_usage = $opt{SpaceSaved};
	# should be a nice way to do this so that if we have megs rather than bytes we can use
	# the same comparisons and just change the units
	if($nice_usage >= 1099511627776){
		$nice_usage /=1099511627776;
		$nice_usage = sprintf("%.2f Ter",$nice_usage);
	}elsif($nice_usage >= 1073741824){
		$nice_usage /=1073741824;
		$nice_usage = sprintf("%.2f Gig",$nice_usage); 
	}elsif($nice_usage >= 1048576){
		$nice_usage /=1048576;
		$nice_usage = sprintf("%.2f Meg",$nice_usage);
	}elsif($nice_usage >= 1024){
		$nice_usage /=1024;
		$nice_usage = sprintf("%.2f k",$nice_usage);
	}else{
		$nice_usage = sprintf("%.2f bytes",$nice_usage);
	}
	print "Saved: $nice_usage ($opt{SpaceSaved} bytes) [$opt{START}]\n" if $opt{verbose}>=1;
 	if($opt{print_tail}){ warn "\n"; warn `tail -n1 .ooe.log`; } 
}else{
	create_hash($opt{BASE_PATH},$hash);
}
