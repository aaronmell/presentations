#### To configure the backend you need to run terraform init with the following commands
/*
terraform init \
-reconfigure \
-backend-config="region=us-west-2" \
-backend-config="profile=personal"
*/

provider "aws" {
  region = "us-east-2"
  profile = "personal"
}

