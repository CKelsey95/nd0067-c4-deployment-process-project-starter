# Infrastructure Description

This is basically what AWS stuff my app uses and how it all connects.

## Diagram

```
                         +-----------+
                         |  Browser  |
                         +-----------+
                           /       \
                          /         \
                         v           v
        +----------------------+   +------------------------+
        |   S3 static website  |   |    Elastic Beanstalk    |
        |  (Angular frontend)  |   |    (Node.js API/EC2)    |
        +----------------------+   +------------------------+
                    ^                     |          |
                    |                     v          v
                    |          +----------------+  +----------------+
                    |          |  RDS Postgres  |  |  S3 image bkt  |
                    |          | (users, feed)  |  | (uploads)      |
                    |          +----------------+  +----------------+
                    |                                     ^
                    +-------------- signed upload URL -----+
```

## Frontend - S3

The frontend is just the compiled Angular app (html/js/css files) sitting in an S3 bucket called `udacity-ckelsey95`. I turned on static website hosting for it so it acts like a normal website.

Had to set both the index doc AND the error doc to `index.html` because Angular does its own routing on the client side, so if you refresh on like `/feed` there's no actual file called `feed`, S3 has to just fall back to index.html and let angular figure out the route.

Also had to add a bucket policy to allow public read on everything in the bucket (`s3:GetObject` on `arn:aws:s3:::udacity-ckelsey95/*`) and turn off "block public access" or nobody can actually see the site.

url: http://udacity-ckelsey95.s3-website.us-east-2.amazonaws.com

## API - Elastic Beanstalk

This runs the backend (express/typescript api). Environment is called `Udacity-project-env`, app is `udacity-project`, running on Node.js 24 / Amazon Linux 2023, single instance, t3.micro.

The build script compiles the typescript, copies some config stuff into a `www` folder and zips it up (`www/Archive.zip`). Then `eb deploy` uses that zip instead of trying to zip the git repo itself (had to add `deploy: artifact: www/Archive.zip` to the elasticbeanstalk config file to make that happen, otherwise it defaults to zipping from git and it was missing files).

Environment variables set in the EB console (Configuration > Software):
- POSTGRES_USERNAME
- POSTGRES_PASSWORD
- POSTGRES_DB
- POSTGRES_HOST
- AWS_REGION
- AWS_BUCKET
- URL
- JWT_SECRET

Made two IAM Roles for this:
- service role (`aws-elasticbeanstalk-service-role`) - lets EB manage the environment itself
- ec2 instance role (`aws-elasticbeanstalk-ec2-role`) - this is what the actual running app uses, needed to add S3 permissions here so the api could generate signed upload urls, otherwise uploads failed with AccessDenied

url: http://udacity-project-env.eba-sn8exprp.us-east-2.elasticbeanstalk.com

## Database - RDS

Postgres instance named `udacityprojectsandbox`, database inside it also named `udacityprojectsandbox` (these are two different things and it confused me for a while, the instance and the db aren't automatically the same).

Had to:
- open up the security group so EB's instance could actually reach port 5432
- turn off forced SSL (`rds.force_ssl` param) since the app's sequelize config doesn't do SSL
- manually create the database itself, it doesn't exist just because the RDS instance exists

The actual tables (Users, FeedItems) get made automatically when the app starts, sequelize does that with `sync()`.

## Images - S3

Same bucket as the frontend (`udacity-ckelsey95`). The api hands out a signed url and the browser uploads the image straight to s3, it doesn't go through the api server itself.
