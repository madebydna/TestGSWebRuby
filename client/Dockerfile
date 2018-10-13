FROM node:9.4.0

RUN mkdir -p /srv/frontend
WORKDIR /srv/frontend

RUN mkdir -p /srv/app/assets/webpack

COPY package*.json ./
RUN npm install
COPY . .

CMD ["npm", "run", "build:development"]