## Should only need to login once
docker compose run --rm q login
## Start the chat with Q cli in a safe mode (have to approve every execution)
docker compose run --rm q chat
## Start the chat with Q cli and trust it to run any command to avoid having to accept every request
docker compose run --rm q chat --trust-all-tools
## Quit Q cli
/quit

