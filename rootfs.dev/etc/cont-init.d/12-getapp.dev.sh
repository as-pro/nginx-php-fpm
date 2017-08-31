#!/usr/bin/with-contenv sh

# Dont pull code down if the .git folder exists
if [ -n "$APP_DIR" ] && [ ! -d "$APP_DIR/.git" ]; then

    # Pull down code from git for our site!
    if [ ! -z "$GIT_REPO" ]; then
        # Remove the test index file if you are pulling in a git repo
        if [ ! -z ${REMOVE_FILES} ] && [ ${REMOVE_FILES} == 0 ]; then
            echo "skiping removal of files"
        else
            rm -Rf $APP_DIR/*
        fi

        GIT_COMMAND='git clone '
        if [ ! -z "$GIT_BRANCH" ]; then
            GIT_COMMAND=${GIT_COMMAND}" -b ${GIT_BRANCH}"
        fi

        if [ -z "$GIT_USERNAME" ] && [ -z "$GIT_PERSONAL_TOKEN" ]; then
            echo "GIT_USERNAME or GIT_PERSONAL_TOKEN not set!"
        else
            if [[ "$GIT_USE_SSH" == "1" ]]; then
                GIT_COMMAND=${GIT_COMMAND}" ${GIT_REPO}"
            else
                GIT_COMMAND=${GIT_COMMAND}" https://${GIT_USERNAME}:${GIT_PERSONAL_TOKEN}@${GIT_REPO}"
            fi
        fi

        ${GIT_COMMAND} $APP_DIR || exit 1

        # Try auto install for composer
        if [ -f "$APP_DIR/composer.lock" ]; then
            composer install --working-dir=$APP_DIR
        fi

        chown -Rf nginx:nginx $APP_DIR

    fi

fi
