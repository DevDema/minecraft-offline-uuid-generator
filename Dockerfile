# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install build dependencies and necessary utilities
RUN apk add --no-cache \
    autoconf \
    automake \
    libtool \
    make \
    gcc \
    g++ \
    python3 \
    git \
    bash \
    zlib-dev \
    cpio \
    file \
    nasm

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json to leverage Docker layer caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Build the application
RUN npm run build

# Stage 2: Serve the application using Nginx
FROM nginx:stable-alpine

# Remove the default Nginx static assets
#RUN rm -rf /usr/share/nginx/html/*

# Copy the built files from the builder stage to Nginx's html directory
COPY --from=builder /app/dist /usr/share/nginx/html

# (Optional) Copy custom Nginx configuration
# If you have a custom nginx.conf, uncomment the following line and ensure 
# you have an nginx.conf file in your project root.
# COPY nginx.conf /etc/nginx/nginx.conf

# Expose port 8080
EXPOSE 8080

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]