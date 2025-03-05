# Budgeting-Application

A budgeting application with Firebase authentication and cryptocurrency wallet tracking.

## Deployment to AWS Elastic Beanstalk

This application is configured for deployment to AWS Elastic Beanstalk. Follow these steps to deploy:

### Prerequisites

1. AWS CLI installed and configured with appropriate credentials
2. Maven installed
3. Java 11 installed

### Deployment Steps

1. Clone the repository:
   ```
   git clone https://github.com/Jkollar116/Budgeting-Application.git
   cd Budgeting-Application
   ```

2. Update the Firebase API key in `.elasticbeanstalk/options.json` if needed.

3. Run the deployment script:
   ```
   ./deploy.sh
   ```

4. The script will:
   - Build the application using Maven
   - Create an application bundle
   - Upload the bundle to S3
   - Create or update the Elastic Beanstalk application and environment
   - Deploy the application

5. Once deployment is complete, the application will be available at:
   ```
   https://budgeting-application-env.us-east-2.elasticbeanstalk.com
   ```

### Custom Domain Setup

To use the custom domain `cashclimb.net`:

1. In AWS Route 53, create a hosted zone for `cashclimb.net` if it doesn't exist.

2. Create an A record that points to the Elastic Beanstalk environment:
   - Name: `cashclimb.net`
   - Type: A
   - Alias: Yes
   - Target: Your Elastic Beanstalk environment URL

3. Create a CNAME record for the www subdomain:
   - Name: `www.cashclimb.net`
   - Type: CNAME
   - Value: `cashclimb.net`

4. Wait for DNS propagation (can take up to 48 hours).

### Environment Variables

The application uses the following environment variables:

- `FIREBASE_API_KEY`: Firebase API key for authentication
- `STATIC_FILES_PATH`: Path to static files on the server
- `PORT`: Port on which the application runs

These are automatically set by the Elastic Beanstalk configuration.

## Local Development

To run the application locally:

```
mvn clean package
java -jar target/firebase-login-app-1.0.0.jar
```

The application will be available at `http://localhost:8000`.
