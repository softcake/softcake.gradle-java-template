#!/bin/bash
# This script will build the project.

git fsck --full

EXIT_STATUS=0

function strongEcho {
  echo ""
  echo "================ $1 ================="
}

if [ "$TRAVIS_SECURE_ENV_VARS" == "true" ]; then

	strongEcho 'Decrypt secret key file'
	
	openssl aes-256-cbc -pass pass:$SIGNING_PASSPHRASE -in secring.gpg.enc -out secring.gpg -d
	gpg --keyserver keyserver.ubuntu.com --recv-key $SIGNING_KEY

fi

if [ "$TRAVIS_PULL_REQUEST" != "false" ] && [ "$TRAVIS_SECURE_ENV_VARS" == "true" ]; then

	strongEcho 'Build and analyze pull request'

	./gradlew build check sonarqube \
      	-Dsonar.analysis.mode=issues \
      	-Dsonar.github.pullRequest=$TRAVIS_PULL_REQUEST \
      	-Dsonar.github.repository=$TRAVIS_REPO_SLUG \
      	-Dsonar.github.oauth=$SONAR_GITHUB_OAUTH \
      	-Dsonar.host.url=$SONAR_HOST_URL \
      	-Dsonar.login=$SONAR_LOGIN || EXIT_STATUS=$?

elif [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_TAG" == "" ]&& [ "$TRAVIS_BRANCH" != "master" ]; then

  	strongEcho 'Build Branch with Snapshot => Branch ['$TRAVIS_BRANCH']'

    # for snapshots we upload to Sonatype OSS
    ./gradlew snapshot uploadArchives sonarqube --info \
    -Dsonar.host.url=$SONAR_HOST_URL \
    -Dsonar.login=$SONAR_LOGIN \
    -Prelease.travisci=true \
    -Dsonar.projectVersion=$TRAVIS_BRANCH \
    -Psigning.keyId="$SIGNING_KEY" \
    -Psigning.password="$SIGNING_PASSPHRASE" \
    -Psigning.secretKeyRingFile="${TRAVIS_BUILD_DIR}/secring.gpg" || EXIT_STATUS=$?

elif [ "$TRAVIS_PULL_REQUEST" == "false" ] && [ "$TRAVIS_TAG" != "" ]; then

  	strongEcho 'Build Branch for Release => Branch ['$TRAVIS_BRANCH']  Tag ['$TRAVIS_TAG']'

     # for snapshots we upload to Bintray and Sonatype OSS
    ./gradlew final uploadArchives sonarqube --info \
    -PbintrayNoDryRun \
    -Dsonar.host.url=$SONAR_HOST_URL \
    -Dsonar.login=$SONAR_LOGIN \
    -Prelease.travisci=true \
    -Prelease.useLastTag=true \
    -Dsonar.projectVersion=$TRAVIS_BRANCH \
    -Psigning.keyId="$SIGNING_KEY" \
    -Psigning.password="$SIGNING_PASSPHRASE" \
    -Psigning.secretKeyRingFile="${TRAVIS_BUILD_DIR}/secring.gpg" || EXIT_STATUS=$?

    if [[ $EXIT_STATUS -eq 0 ]]; then

 		strongEcho "Update Changelog"

		git config --global user.name "$GIT_NAME"
    	git config --global user.email "$GIT_EMAIL"
    	git config --global credential.helper "store --file=~/.git-credentials"

    	echo "https://$GH_TOKEN:@github.com" > ~/.git-credentials

		git clone --depth=50 --branch=master https://${GH_TOKEN}@github.com/softcake/softcake.gradle-java-template.git softcake/softcake.gradle-java-template
		cd softcake/softcake.gradle-java-template

		git branch --all
		git checkout master

		echo "Current branch is - $(git rev-parse HEAD)"

		./gradlew gitChangelogTask

		git add CHANGELOG.md
		git commit -a -m "Updating Changelog for release '$TRAVIS_TAG'"
		git push origin master

	fi


else

    strongEcho 'Build, no analysis => Branch ['$TRAVIS_BRANCH']  Tag ['$TRAVIS_TAG']  Pull Request ['$TRAVIS_PULL_REQUEST']'

    # Build branch, without any analysis
    ./gradlew build check -Prelease.useLastTag=true || EXIT_STATUS=$?
fi

if [[ $EXIT_STATUS -eq 0 ]]; then

     strongEcho "Successful"
     
fi

exit $EXIT_STATUS
