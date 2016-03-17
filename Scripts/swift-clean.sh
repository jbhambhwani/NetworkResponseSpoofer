# This script runs Swift-Clean app on the project to highlight and autofix coding style issues

if [ $CONFIGURATION = "Release" ]; then
  # For release configuration, do not proceed. Script is only for Debug mode.
  return
fi

if [[ -z ${SKIP_SWIFTCLEAN} || ${SKIP_SWIFTCLEAN} != 1 ]]; then
  if [[ -d "${LOCAL_APPS_DIR}/Swift-Clean.app" ]]; then
    "${LOCAL_APPS_DIR}"/Swift-Clean.app/Contents/Resources/SwiftClean.app/Contents/MacOS/SwiftClean "${SRCROOT}"?@autoFix
  else
    echo "Warning: You have to install and set up Swift-Clean to use its features!"
  fi
fi
