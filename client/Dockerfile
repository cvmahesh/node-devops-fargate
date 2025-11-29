FROM node:18-alpine

WORKDIR /app

COPY package.json ./
RUN npm install --production

COPY client.js ./

CMD ["node", "client.js"]

