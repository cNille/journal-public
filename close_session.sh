#env -i bash --norc   # clean up environment
set +o history
unset PASS || exit 1
CHECKSUM="AOEU"
MY_SALT="f5392e5ad"

read -sp 'Enter password: ' PASS

if [ ! -f ./.lock ]; then
  # Hash the password
  echo "Lock not found. Creating new lock"
  echo "$PASS" | openssl dgst -sha512 | sed 's/^.*= //' > .lock
  echo "Pw hashed"
else
  echo "Verifying password..."

  # Hash password and retrieve .lock
  h=`echo "$PASS" | openssl dgst -sha512 | sed 's/^.*= //'`
  pw=`cat .lock`

  # Ensure correct password
  if [ $h != $pw ] && [ $pw != '' ]; then
    echo "Wrong password!"
    exit
  fi
  echo "Correct password"
fi

# Ensure that there are files to write to db. Otherwise the db will be emptied
if [ -z "$(ls -A ./wip)" ]; then
  echo "Empty wip-folder. Ensure that you have initiated a session"
  exit
fi

# Remove old files in db
rm db/*
touch db/.keep
echo "db clean"

# Update the database with the new files
# Encrypt file and protect it by given password
for f in wip/*
do
  echo $CHECKSUM >> $f
  echo "encrypting $f"
  openssl aes-256-cbc -S "$MY_SALT" -pass pass:"$PASS"  -in $f -out ./db/${f##*wip/} 2>/tmp/err

  # check the saved error-message to see if it exists
  if [ -s /tmp/err ]
  then
    echo "OpenSSL FAIL"
    cat /tmp/err
  else
    rm /tmp/err
  fi

  # Remove last line which is checksum
  sed -i '' -e '$ d' $f
done
unset PASS

# Rm WIP files from curious eyes
rm -rf wip/*
echo "wip clean"
echo "Now journal is safe again. Wihuu!"
