#!/bin/bash -e

NLW_BIN="$ST_CURRENT/nlw/bin"
NLW_DEVBIN="$ST_CURRENT/nlw/dev-bin"

 if [ ! "$1" ]; then
    echo ""
    echo "Usage: run-wiki-tests.bash  PLAN_PAGE [BRANCH [1]]"
    echo "Execute the wikitest plan page, optional [set and update BRANCH [fdefs if 1]]"
    echo "Wikitests are run from the local wikitests wiki"
    echo "Export SELENIUM_PLAN_WORKSPACE and/or SELENIUM_PLAN_SERVER to run from external places"
    echo ""
    exit
fi

FRESHDEV=""
if [ ! -e ~/.nlw ] || [ "$3" ] ; then  
    FRESHDEV="yes"
fi

BRANCH="$2"

PORT=`perl -e 'print $> + 20000'`
PLAN_SERVER=http://`hostname`:$PORT
PLAN_WORKSPACE="wikitests"
[ "$SELENIUM_PLAN_WORKSPACE" ] && PLAN_WORKSPACE="$SELENIUM_PLAN_WORKSPACE"
[ "$SELENIUM_PLAN_SERVER" ] && PLAN_SERVER="$SELENIUM_PLAN_SERVER"

if [ "$BRANCH" ]; then
    ~/stbin/set-branch $BRANCH
    ~/stbin/refresh-branch $BRANCH
fi

USERNAME="wikitester@ken.socialtext.net"
if [ $FRESHDEV ]; then
    $NLW_DEVBIN/fresh-dev-env-from-scratch

    echo Removing all ceqlotron tasks to stop unnecessary indexing
    $NLW_BIN/ceq-rm /.+/
    $NLW_DEVBIN/create-test-data-workspace

    echo Creating user $USERNAME
    $NLW_BIN/st-admin create-user --e $USERNAME >/dev/null 2>/dev/null || true
    $NLW_BIN/st-admin add-workspace-admin --w test-data --e $USERNAME >/dev/null 2>/dev/null || true
    $NLW_BIN/st-admin give-accounts-admin  --e $USERNAME  >/dev/null 2>/dev/null || true
    $NLW_BIN/st-admin give-system-admin  --e $USERNAME  >/dev/null 2>/dev/null || true

    echo "Building wikitests"
    $NLW_DEVBIN/wikitests-to-wiki

    $NLW_DEVBIN/st-socialcalc enable

    echo No longer Populating reports DB
    #$NLW_DEVBIN/st-populate-reports-db

    echo Importing latest help wiki
    $NLW_BIN/st-admin delete-workspace --w help-en --no-export
    $NLW_BIN/st-admin import-workspace --t $ST_CURRENT/nlw/share/l10n/help/help-en.tar.gz
fi

cd $ST_CURRENT
echo plan-page is $1
echo plan-workspace is $PLAN_WORKSPACE
echo plan-server is $PLAN_SERVER

~/stbin/run-wiki-tests --no-maximize --test-username "$USERNAME" --test-email "$USERNAME" --plan-server "$PLAN_SERVER" --plan-workspace "$PLAN_WORKSPACE" --timeout 60000 --plan-page "$1" >& testcases.out&
echo RUNNING ... tail -f $ST_CURRENT/testcases.out to monitor progress
