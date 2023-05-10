## Architecture Guide

Before you run any templates, be sure to create an S3 bucket to contain
all of our artifacts for CloudFormation.

```
aws s3 mk s3://cfn-artifacts-ganeshpondy
export CFN_BUCKET="cfn-artifacts-ganeshpondy"
gp env CFN_BUCKET="cfn-artifacts-ganeshpondy"
```

> remember bucket names are unique to the provide code example you may need to adjust
