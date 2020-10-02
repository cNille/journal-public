#env -i bash --norc   # clean up environment
set +o history
unset PASS || exit 1
CHECKSUM="AOEU"
MY_SALT="f5392e5ad"

read -sp 'Enter password: ' PASS

# Hash the password and retrieve .lock
h=`echo "$PASS" | openssl dgst -sha512 | sed 's/^.*= //'`
pw=`cat .lock`

# Ensure that it is the correct password
if [ $h != $pw ] && [ $pw != '' ]; then
  echo "Wrong password"
  exit
else
  echo "Correct password"
fi

if [ ! -d .tmp ]; then
  mkdir .tmp
fi

# encrypt file and protect it by given password
for f in db/*
do
  filename=${f##*db/}
  openssl aes-256-cbc -S "$MY_SALT" -pass pass:"$PASS"  -d -in $f -out ./.tmp/$filename 2>/tmp/err
  # check the saved error-message to see if it exists
  if [ -s /tmp/err ]
  then
    echo "OpenSSL FAIL"
    cat /tmp/err
  else
    rm /tmp/err
  fi

  # Compare checksums
  checksum=`tail -1 ./.tmp/$filename`
  if [ "$CHECKSUM" != "$checksum" ]; then
    echo "Checksum failed: Wrong pw"
    exit
  fi

  # Remove last line which is checksum
  sed -i '' -e '$ d' ./.tmp/$filename
done
unset PASS

if [ ! -d wip ]; then
  mkdir wip
fi

mv .tmp/* wip
