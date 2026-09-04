# Pipeline Description

Explaining what the CircleCI pipeline does. Config is in `.circleci/config.yml`.

## Diagram

```
[push to master]
       |
       v
   +-------+       +------+       +--------+
   | build | ----> | hold | ----> | deploy |
   +-------+       +------+       +--------+
   install/lint     manual        deploy frontend -> S3
   build FE+API     approval      deploy API -> Elastic Beanstalk
```

## When it runs

Runs on every push. But the hold + deploy part only happens on the master branch (there's a branch filter on it). If you push to some other branch it just does the build job and stops.

## Step 1: build

Runs in a node docker image. Basically:
1. installs node
2. checks out the code
3. installs frontend deps (npm install -f)
4. installs api deps
5. lints the frontend
6. builds the frontend
7. builds the api (this is also where it makes the Archive.zip file that gets deployed later)

if any of these fail the whole thing stops, nothing after this runs.

## Step 2: hold

this is just a manual approval button. pipeline literally pauses and waits for a person to click approve in the circleci dashboard before it goes any further. it's basically a safety check so a build doesn't just auto deploy to prod the second it passes.

## Step 3: deploy

this one uses a different docker image (cimg/base) and installs the eb cli + aws cli using orbs. it needs AWS_ACCESS_KEY_ID / AWS_SECRET_ACCESS_KEY / AWS_DEFAULT_REGION which are set as env vars in the circleci project settings (not in the code, that would be bad).

it deploys 2 things:
- frontend: builds it again then runs a deploy.sh script that copies the built files to the s3 bucket with aws s3 cp
- api: builds it (makes Archive.zip again) then does `eb use <environment name>` and `eb deploy`

## random notes / gotchas

- the `.elasticbeanstalk` folder is normally in .gitignore by default but i had to actually commit it so circleci has the eb config to deploy with. it doesn't have any secrets in it so it's fine to commit.
- had to remove a `profile: eb-cli` line from the eb config because that profile only exists on my own laptop, not in circleci, and it made deploys fail there.
