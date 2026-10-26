#!/bin/bash
# SessionStart hook for Claude Code cloud sessions: installs PHP dependencies
# for each Laravel service so tests and linting work.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

export COMPOSER_ALLOW_SUPERUSER=1

for service in admin main; do
  dir="$CLAUDE_PROJECT_DIR/$service"
  [ -f "$dir/composer.json" ] || continue
  cd "$dir"

  # The Docker images use PHP 7.4; the cloud container has PHP 8.x.
  # Some dev deps (fzaninotto/faker) declare PHP ^7 only, but run fine on 8.x.
  composer install --no-interaction --no-progress --ignore-platform-req=php

  if [ ! -f .env ]; then
    cp .env.example .env
    php artisan key:generate --ansi
  fi
done
