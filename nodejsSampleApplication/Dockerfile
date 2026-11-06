# Base Image
FROM node:latest

# Metadata
LABEL maintainer="Ironhack DevOps"

# Set Working Directory
WORKDIR /var/www

# Copy application files to the container
COPY . .

# Install dependencies
RUN npm install

# Expose application port
EXPOSE 3000

# Define persistent volume for application files
VOLUME [ "/var/www" ]

# Start the application
ENTRYPOINT [ "npm", "start" ]
