  #!/bin/bash
  # Author:xiaoming.wang
  # Date:2015-12-3
  # backup every week and every month 
  # backup today,yestarday and the day before yestarday
  # totally backup 5 versions cause the free Dropbox account only hava 2G space. and one version size is about 200MB.

  main(){
  today=`date +%Y-%m-%d`
  today_3=`date -d "-3 day" +%Y-%m-%d`
  tmp_dir=''
  shellName=$0
  shellName=${shellName:2}

  ### back up today's version 
  if [ -d "./$today" ];
  then
    rm -rf "./$today"
    echo "Delete old $today directory"
  fi
  mkdir "./$today"
  echo "Created new $today directory"
  cd $today
  backup
  cd ./..


  ### delete 3 days before version
  if [ -d "./$today_3" ];
  then
  	rm -rf "./$today_3"
  	echo "Delete old $today_3 directory"
  fi

  ### check weekly version exist and back up
  checkDirExist 'weekly'
  if [[ $tmp_dir != "" ]]
  then
  	echo "weekly backup version exist"
  	day=${today:8:10}
  	tail=` expr $day % 7 `
  	if [[ $tail == "0" ]]
  	then
  		echo "it is time to back weekly version"
  		rm -rf $tmp_dir
  		echo "delete old weekly version"
  		mkdir $today"-weekly"
  		echo "create directory ${today}-weekly"
  		cd $today"-weekly"
                  backup
  		cd ..
  	fi
  else
  	echo "weekly backup version not exist"
  	mkdir $today"-weekly"
  	echo "create directory ${today}-weekly"
  	cd $today"-weekly"
          backup
  	cd ..
  fi
  unset tmp_dir


  ### check monthly version exist and back up
  checkDirExist 'monthly'
  if [[ $tmp_dir != "" ]]
  then
  	echo "monthly backup version exist"
  	month_first_day=${today:0:8}"01-monthly"
  	mtmp_dir=${tmp_dir:0:8}"01-monthly"
  	if [[ $month_first_day == $mtmp_dir ]]
  	then
  		echo "do not need to update monthly version,skip ..."
  	else
  		echo "it is time to backup monthly version"
                  echo "create $month_first_day directory"
                  mkdir $month_first_day 
                  cd $month_first_day
                  backup
                  cd ..
                  echo "delete old monthly direcotory"
                  rm -rf $tmp_dir
  	fi
  else
         month_first_day=${today:0:8}"01-monthly"
         echo "create $month_first_day directory"
         mkdir $month_first_day
         cd $month_first_day
         backup
         cd ..
  fi
  unset tmp_dir

  }

  checkDirExist(){
  for mdir in `ls`
  do
    if [ $mdir != $shellName ]
    then
       if [[ "$mdir" == *"$1"* ]]
       then
         tmp_dir=$mdir
       	 return 1
       fi
    fi
  done
  return 0
  }



  backDirectory(){
  echo "Starting backup directory ..."
  tar -zcPf wordpress.tar.gz     /var/www/html
  tar -zcPf wiki.tar.gz          /var/www/html/wiki
  tar -zcPf etherpad.tar.gz      /home/xiaoming/etherpad-lite
  echo "Backup directory success"
  }

  backDataBase(){
  echo "Starting backup databse ..."
  mysqldump -uroot -p************ wordpress        > wordpress.sql
  mysqldump -uroot -p************ my_wiki          > my_wiki.sql
  mysqldump -uroot -p************ etherpad_db      > etherpad_db.sql
  mysqldump -uroot -p************ --databases my_wiki wordpress  etherpad_db  > mutil.sql
  mysqldump -uroot -p************ --all-databases  > all.sql
  echo "Backup databse success"
  }


  backup(){
  echo "Starting backup"
  backDirectory
  backDataBase
  echo "Backup success !!!"
  }


  main
  echo 'Every thing is all right,have a nice day'
