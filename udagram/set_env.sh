# This file is used for convenience of local development.
# Copy this file to set_env.sh and fill in your own values.
# DO NOT commit set_env.sh — it's gitignored.
export POSTGRES_USERNAME=your_postgres_username
export POSTGRES_PASSWORD=your_postgres_password
export POSTGRES_HOST=your_rds_endpoint.rds.amazonaws.com
export POSTGRES_DB=your_database_name
export AWS_BUCKET=your-bucket-name
export AWS_REGION=us-east-2
export AWS_PROFILE=default
export JWT_SECRET=your_jwt_secret
export PORT=8080
export URL=http://localhost:8100