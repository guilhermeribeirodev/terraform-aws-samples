variable "region" {
 default = "us-east-1"
}
variable "shared_cred_file" {
 default = "/Users/guilhermeribeiro/.aws/credentials"
}
variable "SSH_PUBLIC_KEY" {
  default = "/Users/guilhermeribeiro/.ssh/keypairtest1.pub"
}
variable "service_name" {
  type    = "string"
  default = "nodejs-app-test"
}
variable "service_description" {
  type    = "string"
  default = "Ember App Test"
}
variable "solution_stack_name" {
  type    = "string"
  default = "64bit Amazon Linux 2018.03 v2.12.12 running Docker 18.06.1-ce"
}

#======================================================================

provider "aws" {
  region     = "${var.region}"
  shared_credentials_file = "${var.shared_cred_file}"
  profile = "default"
}

#======================================================================

resource "aws_elastic_beanstalk_application" "fe-sample-ember" {
  #source    = "git clone git@bitbucket.org:guilherme_ribeiro/emberjs-sample.git?ref=master"
  name        = "ember-sample"
  description = "A Ember hello world running on EB"
}

resource "aws_elastic_beanstalk_environment" "dev" {
  name                = "tf-dev-name"
  application         = "${aws_elastic_beanstalk_application.tftest.name}"
  solution_stack_name = "${var.solution_stack_name}"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "EC2KeyName"
    value = "${aws_key_pair.app.id}"
  }
}

# key pair
resource "aws_key_pair" "app" {
  key_name = "app-prod" 
  public_key = "${file("${var.SSH_PUBLIC_KEY}")}"
}

#======================================================================

resource "aws_ecr_repository" "ember" {
  name = "ember-sample-fe"
}

resource "aws_ecr_repository_policy" "ember-sample-dev" {
  repository = "${aws_ecr_repository.ember.name}"

  policy = <<EOF
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Sid": "new policy",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "ecr:GetDownloadUrlForLayer",
                "ecr:BatchGetImage",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage",
                "ecr:InitiateLayerUpload",
                "ecr:UploadLayerPart",
                "ecr:CompleteLayerUpload",
                "ecr:DescribeRepositories",
                "ecr:GetRepositoryPolicy",
                "ecr:ListImages",
                "ecr:DeleteRepository",
                "ecr:BatchDeleteImage",
                "ecr:SetRepositoryPolicy",
                "ecr:DeleteRepositoryPolicy"
            ]
        }
    ]
}
EOF
}

##################################################
## App Variables Output
##################################################
# output "eb_cname" {
#   value = "${aws_elastic_beanstalk_environment.eb_env.cname}"
# }
