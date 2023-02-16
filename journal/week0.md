# Week 0 — Billing and Architecture

## 1. AWS User

Root Account should not be used for Regular Operations and Security Reasons. So, we have Separate Account Created for All Operations and Download the Access Key ID and SECRET ACCESS KEY Details.

## 2. AWS CLI

Connecting CloudShell to execute and Test AWS CLI Commands and get familiar ourselves will AWS Commands


```YAML
CLOUDSHELL OUTPUTS
--------------------

[cloudshell-user@ip-IPDetail ~]$ aws --cli-auto-prompt 
> aws sts get-caller-identity
{
    "UserId": "",
    "Account": "",
    "Arn": "arn:aws:iam:::user/"
}

[cloudshell-user@ip-IPDetail ~]$ aws account get-contact-information
{
    "ContactInformation": {
        "AddressLine1": ",",
        "AddressLine2": " ,",
        "City": "",
        "CountryCode": "",
        "FullName": "",
        "PhoneNumber": "",
        "PostalCode": "",
        "StateOrRegion": ""
    }
}
[cloudshell-user@ip-IPDetail ~]$ 
```

Connecting GitPod to access the GitHub Codes and Installed AWS CLI in GitPod and Exported AWS Account Details as Global Environment Variables

Added Following Lines in ".gitpod.yml" file to install AWS in GitPod

```YAML
tasks:
  - name: aws-cli
    env:
      AWS_CLI_AUTO_PROMPT: on-partial
    init: |
      cd /workspace
      curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
      unzip awscliv2.zip
      sudo ./aws/install
      cd $THEIA_WORKSPACE_ROOT
```
Below Commands are used to Exporting AWS Credentials as Goble Environment Variables
```BASH
gitpod /workspace $ export AWS_ACCESS_KEY_ID=""
gitpod /workspace $ export AWS_SECRET_ACCESS_KEY=""
gitpod /workspace $ export AWS_DEFAULT_REGION="ap-south-1"

gitpod /workspace $ env | grep -i aws_
AWS_DEFAULT_REGION=ap-south-1
AWS_SECRET_ACCESS_KEY=
AWS_ACCESS_KEY_ID=

gitpod /workspace $ aws sts get-caller-identity
{
    "UserId": "",
    "Account": "",
    "Arn": "arn:aws:iam:::user/"
}
gitpod /workspace $ 
```

To Permentally Export the Variables in GitPod Profile.

```BASH
gp env AWS_ACCESS_KEY_ID=""
gp env AWS_SECRET_ACCESS_KEY=""
gp env AWS_DEFAULT_REGION="ap-south-1"
gp env AWS_ACCOUNT_ID=""
```


## 3. Configuring Budget alerts

1. Create Diredtory "aws/json/" Under [aws-bootcamp-cruddur-2023](https://github.com/ganeshpondy/aws-bootcamp-cruddur-2023 "github.com/ganeshpondy/aws-bootcamp-cruddur-2023") Repo.

2. Update below two Files
    budget-notifications-with-subscribers.json
    budget.json

```javascript
aws budgets create-budget \
    --account-id $AWS_ACCOUNT_ID \
    --budget file://aws/json/budget.json \
    --notifications-with-subscribers file://aws/json/budget-notifications-with-subscribers.json
```

![Budget Image](./Images/Week0/Budgets.JPG)
#
## 4. Creating sns topics for alerts
1. Create Topic

```javascript
gitpod /workspace/aws-bootcamp-cruddur-2023 (main) $ aws sns create-topic --name billing-alarm
{
    "TopicArn": "arn:aws:sns:ap-south-1:id:billing-alarm"
} 
```

![SNS Image](./Images/Week0/SNS1.JPG)

2. subscribe SNS with the Topic arn id
```
gitpod /workspace/aws-bootcamp-cruddur-2023 (main) $ aws sns subscribe \
>     --topic-arn arn:aws:sns:ap-south-1:id:billing-alarm \
>     --protocol email \
>     --notification-endpoint mail@gmail.com
{
    "SubscriptionArn": "pending confirmation"
}
```
![SNS Topics](./Images/Week0/SNS_Topics.JPG)
#
## 5. Creating cloudwatch Alarms through alarm-config.json file

```javascript
aws cloudwatch put-metric-alarm --cli-input-json file://aws/json/alarm-config.json
```
![cloudwatch Alarm](./Images/Week0/CloudWatch.JPG)

#
## 6. Logical Diagram for the Cruddur Application

![Logical Diagram](./Images/Week0/Logical-Diagram.jpg)
#
## 7. Conceptual Chart

![Conceptual Chart](./Images/Week0/Cruddur-Conceptual-Diagram.jpeg)

[Conceptual Chart LucidChart Link](https://lucid.app/lucidchart/9568f89a-ebb8-4f91-b096-5aedf2614f42/edit?invitationId=inv_4361516c-c455-4f36-b78a-1dbb3fe6f548)
#
## 8. CI CD Flow Diagram

![CICD FLow](./Images/Week0/CICD_FLow.jpeg)

[CICD FLow LucidChart Link](https://lucid.app/lucidchart/dcf4deff-2518-40c6-8dc1-399bc17ad858/edit?invitationId=inv_5510c85d-8dd4-4aa6-b27e-70bbbbdde270)
#
## 9. GitOpd Push Error 

Faced challenge When Push Code First time from GitPod to GitHub

Below is the Error 

![gitpod error](./Images/Week0/GitPod_err_1.jpg)

To Resolve the Issue, Follw the Below Steps

1. Click Account at the Left Side Bottom and Select "Open Settings"

<img src="./Images/Week0/GitPod_err_2.1"  width="60%" height="30%">

2. Click "Integrations" and Select the "GitHub" Account

<img src="./Images/Week0/GitPod_err_3.jpg"  width="60%" height="30%">

3. CLick the 3dots and Edit Permissions
<img src="./Images/Week0/GitPod_err_2.jpg"  width="60%" height="30%">

4. Enable the "public_repo" box

<img src="./Images/Week0/GitPod_err_4.jpg"  width="60%" height="30%">

5. Then Retry to Push the Code to GitHub Repo. This time it will be Successful Push.

####################################################

## 10. More on Cost Management
### 10.1 Cost Allocation Tags

By Default, Cost Allocation Tags service is not activating, we have to select the tags and Activate the Services. Its will be very handy to calculate the Cost using the resources Tags.

Follow the below steps to enable:

1. Go to AWS Billing Page, Click on "Cost allocation tags" on left panel
1. Then Select the "Tag Key", which need to activate.
3. Click the "Active" Button at the right side of the box

<img src="./Images/Week0/Cost_Allocation_Tags.JPG"  width="100%" height="100%">

#
### 10.2 Cost Categories

Cost Categories automatically categorizes your cost information into custom groups. 

Follow the below steps Create Cost Categories:

1. Go to AWS Billing Page, Click on "Cost Categories" on left panel
2. Click on "Create cost Category"
3. Fill the Report name and other details

<img src="./Images/Week0/Cost_Categories_2.JPG"  width="100%" height="100%">
<img src="./Images/Week0/Cost_Categories_3.JPG"  width="100%" height="100%">
<img src="./Images/Week0/Cost_Categories_1.JPG"  width="100%" height="100%">

#
### 10.3 Cost Explorer

Cost Explorer will provide helpful cost and usage insights.

Follow the below steps to Create Cost Explorer Reports:

1. Go to AWS Billing Page, Click on "Cost explorer" on left panel under Cost Management.
1. It will New Page for "AWS Cost Management"
1. Click on "Cost Explorer"
1. Specify date range, Granularity (Hours/Daily/Monthly) 
1. Under Filers Specify more details to generate report.

<img src="./Images/Week0/Cost_Explorer_1.JPG"  width="50%" height="50%">

#
<img src="./Images/Week0/Cost_Explorer_2.JPG"  width="100%" height="100%">

#
<img src="./Images/Week0/Cost_Explorer_3.JPG"  width="100%" height="100%">

Step to Follow to Generate Default Reports
1. Click "Reports" under AWS Cost Management" page
1. Select any of the Default report
1. To generate reports

<img src="./Images/Week0/Cost_Explorer_4_Default_Reports.JPG"  width="100%" height="100%">

#
### 10.4 To Get Free Tier Usage Report
1. Go to AWS Billing Page, Click on "Billing Preferences" under Preferences title.
2. Select the Click boxes as below
3. Provide your mail ID to receive Alert mails about the Free Tier Usage.
4. Click on "Save preferences"

<img src="./Images/Week0/Free_Tier_Usage_Alerts.JPG"  width="70%" height="100%">
 
