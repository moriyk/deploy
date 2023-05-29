#!/usr/bin/env sh

cd `dirname $0`

# Load .deploy.env
if [ ! -e ".deploy.env" ];then
  echo ".deploy.env file does not exists."
  exit 1
fi
export $(cat .deploy.env | grep -v "#" | xargs)

# Local
DIR=`pwd`
SRCPATH=$(dirname $DIR)
DIRNAME=$(basename $DIR)

# Remote
USER=${USER:-root}
HOST=${HOST:-example.com}
PORT=${PORT:-22}
DESTPATH=${DESTPATH:-~/}

# Deploy
IDENTITYFILE=${IDENTITYFILE:-~/.ssh/id_rsa}
alias ssh='ssh -o StrictHostKeyChecking=no -i $IDENTITYFILE'

cd $SRCPATH; tar czf - $DIRNAME | ssh $USER@$HOST -p $PORT "(mkdir -p $DESTPATH && cd $DESTPATH && rm -rf * && tar xzf -)"

# Remove unnecessary files
UNNECESSARY=$(printf '%s\n' "$IGNORE_FILES" | sed 's/:/ /g')
ssh $USER@$HOST -p $PORT "cd $DESTPATH/$DIRNAME && rm -rf $UNNECESSARY"