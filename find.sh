#!/bin/bash
CREW_PREFIX=/usr/local
PWA_PREFIX=/usr/local/lib/pwa
FLASK_APP=$PWA_PREFIX/main.py
tools=$PWA_PREFIX/tools
var=`find /usr/local/ -name *.desktop 2> /dev/null`
rm ~/deploy.list
touch ~/deploy.list
for file in $var
do
  stop=false
  i=0
  icon=`grep "Icon=" $file | sed -n '1p' | cut -d "=" -f 2`
  appname=`grep "Name=" $file | sed -n '1p' | cut -d "=" -f 2`
  appname=`echo $appname | sed --expression="s/\-/\_/g"`
  appname=`echo $appname | sed --expression="s/'\\\\''/or/g"`
  appname=`echo $appname | sed --expression="s/\//or/g"`
  webpath="${appname// /}$i"
  path=`grep "Exec=" $file | sed -n '1p'| cut -d "=" -f 2`
    if [[ $path != "" ]]
    then
    while [ $stop != ture ]
    do
      if [[ "`grep ${webpath} ~/deploy.list`" != "" ]]
      then 
      i=$((i+1))
      webpath=${appname// /}$i
      else
      stop=ture
      fi
    done
    mkdir -p $PWA_PREFIX/$webpath/templates/
    cp -r $tools/* $PWA_PREFIX/$webpath/templates/
    mv $PWA_PREFIX/$webpath/templates/manifest.json.bak $PWA_PREFIX/$webpath/templates/manifest.json
    sed -i "s/linuxapp/$appname/g" $PWA_PREFIX/$webpath/templates/manifest.json
    sed -i "s/unixapp/$webpath/g" $PWA_PREFIX/$webpath/templates/manifest.json
    #######################
    echo " " >> $FLASK_APP
    echo "@app.route('/$webpath/$webpath.app')" >> $FLASK_APP
    echo "def $webpath():" >> $FLASK_APP
    echo "  def ${webpath}_run():" >> $FLASK_APP
    echo "    os.system('$path')" >> $FLASK_APP
    echo "  start_$webpath = Thread(target=${webpath}_run)" >> $FLASK_APP
    echo "  start_$webpath.start()" >> $FLASK_APP
    echo "  return 'You can close this window now'" >> $FLASK_APP
    echo "@app.route('/$webpath/')" >> $FLASK_APP
    echo "def installer_${webpath}():" >> $FLASK_APP
    echo "    return render_template('installer.html')" >> $FLASK_APP
    echo "@app.route('/$webpath/<path:path>')" >> $FLASK_APP
    echo "def ${webpath}_path(path):" >> $FLASK_APP
    echo "    if path.endswith(('.png', 'manifest.json')):" >> $FLASK_APP
    echo "        return send_from_directory('$webpath/templates', path)" >> $FLASK_APP
    echo " " >> $FLASK_APP
    #######################
    iconpath=`bash $tools/autogen-icon.sh $icon $CREW_PREFIX $appname`
    cp $iconpath $PWA_PREFIX/$webpath/templates/icon/brew.png
    rm $iconpath
    #######################
    echo "localhost:5000/$webpath - $appname" >> ~/deploy.list
    echo "Shortcut for $appname deployed!"
  fi
done
echo "Deploy list can be found at ~/deploy.list"