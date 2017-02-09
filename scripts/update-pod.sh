set -e

if [ -z "$TRAVIS_TAG" ]; then
  echo "this is not a tag, stop here..."
  exit 0
fi

pod trunk push YumiMediationAdapters.podspec --use-libraries --allow-warnings --verbose
