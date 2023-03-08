# syntax=docker/dockerfile:1
   
FROM node:18.14.0
WORKDIR /movies
COPY . .
RUN npm install
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]