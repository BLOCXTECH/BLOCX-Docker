#!/usr/bin/env bash

if [[ ! -d /root/.blocx/sentinel ]]; then 
  cd /root/.blocx
  git clone https://github.com/BLOCXTECH/sentinel.git
  cd sentinel
  virtualenv venv
  venv/bin/pip install -r requirements.txt
  venv/bin/python bin/sentinel.py
fi

if [[ ! -f /tmp/crone ]]; then
    sleep 120
    echo -e "Added crone job for fill as gaps..."
    (crontab -l -u "$USER" 2>/dev/null; echo "* * * * * cd /root/.blocx/sentinel && ./venv/bin/python bin/sentinel.py  2>&1 >> sentinel-cron.log") | crontab -
    (crontab -l -u "$USER" 2>/dev/null; echo "* * * * * pidof blocxd || /root/.blocx/blocxd") | crontab -
   
    echo -e "Cron job added!" >> /tmp/crone
 else
    echo -e "Cron job already exist..."
 fi

