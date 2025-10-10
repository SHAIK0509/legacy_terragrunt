#!/bin/bash
set -eo pipefail

OBJECT_PATH="s3://${2}/${3}"

if aws s3api head-object --region "$1" --bucket "$2" --key "$3" >/dev/null 2>&1; then
  printf '{"status": "ok"}\n'
else
  printf '{"status": "%s does not exist"}\n' "$OBJECT_PATH"
fi

exit 0
