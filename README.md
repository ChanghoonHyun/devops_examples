# Terraform IaC example

![architecture](docs/images/architecture.png "architecture")

## Requirements
- aws cli
- terraform

## Install aws cli
```sh
$ pip install awscli --upgrade --user
```

## Install terrafrom
On a mac:
```sh
$ brew install terraform
```

## Configure aws cli
```sh
$ aws configure
AWS Access Key ID [None]: ${your-access-key}
AWS Secret Access Key [None]: ${your-secret-key}
Default region name [None]: ap-northeast-2
Default output format [None]: json
```

## How to run
### initialize
```sh
$ terraform init
```
### confirm plan
```sh
$ terraform plan
```

### run
```sh
$ terraform apply -var db_password=${PASSWORD} -var version=${VERSION}
```