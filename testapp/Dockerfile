#Specifies the base image for the computer.This is starting point for the build.
FROM node:20-alpine

WORKDIR /myapp

#Copy dependency files and install dependencies
COPY packge*.json ./
RUN npm install --production

# Copy rest of the application files
COPY . .

RUN npm install


CMD [ "npm", "start" ]