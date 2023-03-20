# Terraform

To setup multiple environments its always good to have IaaC script which can setup whole infrastructure with just one click.

To run this script we can just run
**terraform.sh** script file and this will setup infra to run RDS database and then it will create AWS parameter store variables which can dynamically be used in our application code instead of hard coding the credentials.

This terraform script can have a step which will create an EC2 machine, then connect EC2 machine and execute the rates.sql script