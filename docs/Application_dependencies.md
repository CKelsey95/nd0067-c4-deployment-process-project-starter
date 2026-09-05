# Application Dependencies

just listing out what libraries/services the app actually needs to run.

## API (udagram-api)

runs on node & typescript

main packages it uses:
- express - the actual web server / routing
- body-parser - reads json out of requests
- cors - lets the frontend (different origin) actually talk to this api
- sequelize / sequelize-typescript - orm, talks to postgres
- pg - the actual postgres driver sequelize uses under the hood
- jsonwebtoken - makes/checks the jwt tokens for login
- bcryptjs - hashes passwords
- aws-sdk - used to make the signed s3 urls for uploading images
- dotenv - loads .env file locally
- email-validator - checks email format on signup
- reflect-metadata - sequelize-typescript needs this for its decorators to work

dev only stuff: typescript, ts-node-dev, eslint (+google config), mocha/chai/chai-http for tests, plus a bunch of @types packages

## Frontend (udagram-frontend)

Angular app, built with the angular cli

there's an environment.ts and environment.prod.ts file that both set `apiHost` which is just the url the frontend uses to hit the backend api. (note: found out the hard way that plain `ng build` uses environment.ts not the prod one unless you pass --configuration production)

## other services (not npm stuff but still "dependencies" for the app to actually work)

- RDS postgres - stores users + feed items
- S3 - hosts the frontend AND stores uploaded images
- elastic beanstalk - runs the api
- IAM - roles/permissions so everything above is allowed to talk to each other
