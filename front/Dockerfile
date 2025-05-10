FROM node:23-alpine

WORKDIR /app
COPY package*.json ./
RUN npm install

CMD ["npm", "run", "dev", "--", "--host"]
