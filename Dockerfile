# Imagem da API em duas fases: a primeira compila o TypeScript, a segunda leva so o necessario
# para rodar. Funciona tanto em Mac com chip ARM quanto em servidor x86.

FROM node:26-alpine AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY tsconfig.json tsconfig.build.json ./
COPY src ./src
RUN npm run build

FROM node:26-alpine
WORKDIR /app
ENV NODE_ENV=production
COPY package.json package-lock.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=build /app/dist ./dist
COPY db/migrations ./db/migrations
USER node
EXPOSE 3000
# Aplica as migracoes pendentes e sobe a API.
CMD ["sh", "-c", "node dist/scripts/migrate.js && node dist/server.js"]
