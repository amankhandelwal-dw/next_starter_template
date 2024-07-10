FROM node:20.11-alpine as builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci
RUN npm i --save-dev sharp
COPY . .

ENV NEXT_SHARP_PATH=/app/node_modules/sharp

RUN NODE_ENV=production npm run build && npm prune --production

FROM node:20.11-alpine as runner
WORKDIR /app

ENV NODE_ENV production
ENV NEXT_SHARP_PATH=/app/node_modules/sharp
COPY --from=builder /app/node_modules/sharp /app/node_modules/sharp
COPY --from=builder /app/public ./public
COPY --from=builder /app/.next/standalone ./
COPY --from=builder /app/.next/static ./.next/static
EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]