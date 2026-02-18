Dockerizing Math Fact Invaders

This repository is a static site (HTML/CSS/JS). The included Docker setup uses nginx to serve the files.

Quick start (build and run):

```powershell
# Build and run in foreground
docker-compose up --build

# Or build and run detached
docker-compose up --build -d
```

Open http://localhost/ (the container exposes port 80). The server defaults to serving `mathdex.html` as the index.

Development notes

- For live edits during development, uncomment the `volumes` section in `docker-compose.yml` to mount the project into the container. That will let you edit files locally and immediately see changes.
- For production, don't mount the volume: build the image and deploy the static image.

Files added

- `Dockerfile` – builds an nginx image and copies the site files
- `docker-compose.yml` – service to build and run the image
- `.dockerignore` – keeps build context small
- `default.conf` – nginx config that sets `mathdex.html` as the default index
- `README.md` – this file

Troubleshooting

- If port 80 is in use, change the port mapping in `docker-compose.yml` to e.g. `"8080:80"` and open http://localhost:8080/
- If you need to confirm the server is responding, run (from your host):

```powershell
# Expect an HTTP 200 response and HTML
Invoke-WebRequest -UseBasicParsing http://localhost/ | Select-Object -Property StatusCode, ContentLength
```
