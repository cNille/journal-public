# Journal

This is a minimalistic digital dairy built with bash commands. 
The thought is of using a symmetric key to encrypt all journal-posts into
a database. The posts are in form of files in the wip-folder 
(WORK-IN-PROGRESS). The database is the db folder which will contain the same
files, but encrypted. 

There are two scripts right now;
- `init_session.sh`
- `close_session.sh`


## Initial session

The workflow is that the first time you just create files in the wip-folder
and work. When you want to save your journal you use `close_session.sh`. It 
will prompt for a secret for the symmetric encryption. The files will be moved
to the `db` folder and a lock will be created. 

The lock is the hash of the secret. 

## Init second session

Next time you want to update or read your journal you use `init_session.sh`.
It will prompt for the secret and check the hash of it against the lock.

If correct secret-hash it will decrypt the database. Here we check for the 
checksum variable to ensure that it was indeed the correct secret. This because
the lock file could be tampered with. 

If correct checksum then it will move the db files to the wip folder.

## Save second session

Same as before, but this time the secret has to correspond to the earlier 
secret. This because we check against the lock if it exists. 

To select a new secret you have to remove the lock file. 


# Versioning
The wip folder is gitignored for obvious reasons, but not the db. This because
it is encrypted and only can be decrypted with your secret. 

Now we can use git to version the journal. This feature might not be 
interesting for everyone. But a nice side-effect is that we now can store
the journal in a private repo in github. Then we won't loose our
journal if something happens to our computer. And because we use bash, then we
can access our journal from any unix-computer. 

A security feature recommended when using git is to sign all commits with
a gpg key. Then the history won't be exposed for tampered history, if someone
gets hold of your repo. 

# ToDos:

- Use zip for the whole WIP for allowing several journals in the db.
- Build an web-app that shows all .md files in the `wip`. --> A static blog.
- Hiding file names (not needed if zip used)
- integrate init and close session with git hooks
- hide db and lock with .db and .lock.
- 
