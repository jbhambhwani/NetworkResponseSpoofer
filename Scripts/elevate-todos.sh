# This script elevates all TODO's and FIXME's in project to warnings so that they get fixed promptly

if [ $CONFIGURATION = "Release" ]; then
  # For release configuration, do not proceed. Script is only for Debug mode.
  return
fi

KEYWORDS="TODO:|FIXME:|\?\?\?:|\!\!\!:"
find "${SRCROOT}" \( -name "*.h" -or -name "*.m" -or -name "*.swift" \) -print0 | xargs -0 egrep --with-filename --line-number --only-matching "($KEYWORDS).*\$" | perl -p -e "s/($KEYWORDS)/ warning: \$1/"
