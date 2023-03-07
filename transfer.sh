#!/bin/sh

command -p curl --version >/dev/null 2>&1 || \
  { printf '"curl" is required but not found. Aborting.\n' >&2; exit 1; }

# Handle options.
encrypt=0
while getopts 'e' opt
do
  case $opt in
    e) command -p gpg --version >/dev/null 2>&1 || \
         { printf '"gpg" is required but not found. Aborting.\n' >&2; exit 1; }
       encrypt=1 ;;
    *) ;;
  esac
done
shift $((OPTIND-1))

# Help menu.
if test $# -eq 0; then
  cat <<EOF >&2
${0##*/} is a command line interface to post file(s)
for sharing at <https://transfer.sh>. Files up to 10GB
can be uploaded and are shared for 14 days.

  Usage:

    ${0##*/} [-e] <file|directory>
    ... | ${0##*/} [-e] <file_name>

  Options:

    -e      Encrypt <file|directory> before uploading.

  Examples:

    # upload file /tmp/test.md
    ${0##*/} /tmp/test.md

    # upload stdout/stderr as test.md
    cat /tmp/test.md | ${0##*/} test.md

    # encrypt file before uploading
    ${0##*/} -e /tmp/test.md
EOF
  exit 1
fi

# Handle file upload.

file="$1"
file_name=$(basename "$file" | sed -e 's/[^a-zA-Z0-9._-]/-/g')
url="https://transfer.sh/$file_name"

if tty >/dev/null 2>&1; then
  test -e "$file" || \
    { printf '%s: No such file or directory.\n' "$file" >&2; exit 1; }

  # Directory.
  if test -d "$file"; then
    if test $encrypt -ne 0; then
      tar -C "$(dirname "$file")" -czf - "$(basename "$file")" | \
        gpg --armor --symmetric --output - | \
        curl --silent --upload-file - "$url.tgz.gpg"
      echo
    else
      tar -C "$(dirname "$file")" -czf - "$(basename "$file")" | \
        curl --progress-bar --upload-file - "$url.tgz" | \
        tee /dev/null
      echo
    fi

  # File.
  else
    if test $encrypt -ne 0; then
      gpg --armor --symmetric --output - "$file" | \
        curl --silent --upload-file - "$url.gpg"
      echo
    else
      curl --progress-bar --upload-file "$file" "$url" | tee /dev/null
      echo
    fi
  fi

# Piped input.
else
  if test $encrypt -ne 0; then
    gpg --armor --symmetric --output - | \
      curl --silent --upload-file - "$url.gpg"
    echo
  else
    curl --progress-bar --upload-file - "$url" | tee /dev/null
    echo
  fi
fi
