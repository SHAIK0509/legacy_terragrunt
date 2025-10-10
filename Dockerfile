# Use the official Nginx image from Docker Hub
FROM nginx:latest

# Set maintainer label (optional)
LABEL maintainer="imran.shaik@prama.ai"

# Copy custom HTML content to the Nginx default HTML directory
COPY ./html /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]
