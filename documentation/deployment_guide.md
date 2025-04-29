# Cal Snap Deployment Guide for DigitalOcean

This guide provides detailed instructions for deploying the Cal Snap application to DigitalOcean using either Droplets or App Platform.

## Option 1: Deploying with DigitalOcean Droplets

### 1. Create a Droplet

1. Log in to your DigitalOcean account.
2. Click "Create" and select "Droplets".
3. Choose a region close to your target users.
4. Select "Marketplace" and choose "Docker" from the list of options.
5. Choose a plan (Basic is sufficient for testing; Standard is recommended for production).
6. Add your SSH key.
7. Choose a hostname (e.g., `calsnap-api`).
8. Click "Create Droplet".

### 2. Connect to Your Droplet

```bash
ssh root@your_droplet_ip
```

### 3. Clone the Repository

```bash
git clone https://github.com/thomas-tahk/cal-ai-foodshot.git
cd cal-ai-foodshot
```

### 4. Configure Environment Variables

1. Create the .env file:

```bash
cp backend/env.example backend/.env
nano backend/.env
```

2. Update the environment variables with your API keys:

```
# Database
DATABASE_URL=postgresql://postgres:password@db:5432/calsnap

# Cloudinary
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret

# Google Cloud Vision API
GOOGLE_APPLICATION_CREDENTIALS=/app/google_credentials.json

# Edamam API
EDAMAM_APP_ID=your_edamam_app_id
EDAMAM_APP_KEY=your_edamam_app_key

# Defaults
DEFAULT_DAILY_CALORIES=2500
```

### 5. Add Google Cloud Credentials

1. Create a service account in Google Cloud and download the JSON key file.
2. Upload the JSON file to your droplet:

```bash
# From your local machine
scp path/to/your-credentials.json root@your_droplet_ip:~/cal-ai-foodshot/google_credentials.json
```

### 6. Deploy with Docker Compose

```bash
cd ~/cal-ai-foodshot
docker-compose up -d
```

### 7. Configure Firewall

1. In the DigitalOcean dashboard, go to "Networking" > "Firewalls".
2. Create a new firewall.
3. Add inbound rules for HTTP (port 80) and HTTPS (port 443).
4. Apply the firewall to your droplet.

### 8. Set Up a Domain (Optional)

1. In the DigitalOcean dashboard, go to "Networking" > "Domains".
2. Add your domain and create appropriate A records pointing to your droplet's IP.

### 9. Set Up SSL with Certbot (Optional)

```bash
apt-get update
apt-get install certbot python3-certbot-nginx
certbot --nginx -d yourdomain.com
```

## Option 2: Deploying with DigitalOcean App Platform

### 1. Prepare Your Repository

Ensure your GitHub repository includes:
- Dockerfile
- docker-compose.yml
- All necessary configuration files

### 2. Create an App

1. In the DigitalOcean dashboard, go to "Apps" > "Create App".
2. Connect to your GitHub repository.
3. Select the branch to deploy (e.g., main).
4. Configure the app:
   - Choose "Dockerfile" as the deployment method.
   - Add a static site for the frontend if needed.

### 3. Configure Environment Variables

1. In the app configuration, go to the "Environment Variables" tab.
2. Add all the environment variables from your backend/.env file.
3. For the Google Cloud credentials, you can either:
   - Add them as a file component
   - Convert the JSON to a base64 string and add it as an environment variable

### 4. Configure Resources

1. Choose the appropriate plan for your resources.
2. Enable auto-deployment if desired.

### 5. Deploy the App

1. Click "Create Resources".
2. Wait for the deployment to complete.
3. Your app will be available at the provided URL.

### 6. Configure Custom Domain (Optional)

1. In the app settings, go to "Domains".
2. Add your custom domain.
3. Configure the DNS records as instructed.

## Updating Your Deployment

### For Droplet Deployment

```bash
cd ~/cal-ai-foodshot
git pull
docker-compose down
docker-compose build
docker-compose up -d
```

### For App Platform

App Platform will automatically redeploy when you push to your repository if auto-deploy is enabled.

## Monitoring and Logs

### For Droplet Deployment

```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# Restart services
docker-compose restart
```

### For App Platform

Use the DigitalOcean dashboard to view logs and monitor your application.

## Troubleshooting

### Common Issues

1. **Database Connection Errors**:
   - Ensure the `DATABASE_URL` is correct in your .env file.
   - Check that the PostgreSQL service is running.

2. **API Key Issues**:
   - Verify all API keys are correctly set in the environment variables.
   - Ensure Google Cloud credentials are properly formatted and accessible.

3. **Frontend Not Connecting to Backend**:
   - Check the API URL in the frontend configuration.
   - Ensure CORS is properly configured in the backend.

### Getting Help

If you encounter issues, consult:
- DigitalOcean's documentation: https://docs.digitalocean.com/
- FastAPI documentation: https://fastapi.tiangolo.com/
- Docker documentation: https://docs.docker.com/ 