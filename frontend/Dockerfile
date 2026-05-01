FROM node:25-alpine AS build

WORKDIR /usr/app

COPY package.json package-lock.json ./
RUN npm install

COPY . .
RUN npm run build

FROM caddy:2-alpine

COPY --from=build /usr/app/dist /srv
COPY Caddyfile /etc/caddy/Caddyfile
