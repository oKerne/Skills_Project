# syntax=docker/dockerfile:1
FROM node:24-bookworm-slim AS dependencies
WORKDIR /app
# Bundling and type checking do not launch Electron.
ENV ELECTRON_SKIP_BINARY_DOWNLOAD=1
COPY package.json package-lock.json ./
RUN npm ci

FROM dependencies AS source
COPY . .

FROM source AS verify
RUN npm run typecheck

FROM source AS build
RUN npm run build

# Export only the bundled files, without dependencies or a desktop runtime.
FROM scratch AS artifacts
COPY --from=build /app/out/ /
