# Use a stable, modern Node version
FROM node:20-slim

# Set the working directory inside the container
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy the rest of the app code
COPY . .

# Run the app
CMD ["node", "index.js"]
