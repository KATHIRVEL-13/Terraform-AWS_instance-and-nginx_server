# Terraform Configuration for Basic AWS Network Infrastructure

This README provides an overview of the Terraform configuration defined in `main.tf`. This configuration sets up a basic Virtual Private Cloud (VPC) in AWS with public and private subnets, along with necessary networking components and two EC2 instances.

## Overview

The `main.tf` file defines the following AWS resources:

* **Virtual Private Cloud (VPC):** A logically isolated virtual network in the AWS cloud, enabling you to launch AWS resources in a virtual network that you've defined.
* **Subnets:** Partitions of the VPC's IP address range where you can launch AWS resources. This configuration creates one public and one private subnet.
* **Internet Gateway (IGW):** A horizontally scaled, redundant, and highly available VPC component that allows communication between instances in your VPC and the internet.
* **Route Tables:** Contain a set of rules, called routes, that are used to determine where network traffic from your subnet or gateway is directed. This configuration creates a public route table for internet-bound traffic and a private route table for NAT Gateway-bound traffic.
* **Route Table Associations:** Links subnets to specific route tables, controlling the routing behavior within those subnets.
* **NAT Gateway:** A Network Address Translation (NAT) service that allows instances in a private subnet to connect to the internet or other AWS services, but prevents the internet from initiating a connection with those instances.
* **Elastic IP (EIP):** A static, public IPv4 address designed for dynamic cloud computing. It's associated with the NAT Gateway to provide it with a stable public IP.
* **Security Group:** Acts as a virtual firewall for your EC2 instances to control inbound and outbound traffic. This configuration creates a security group allowing SSH and HTTP inbound traffic and all outbound traffic.
* **EC2 Instances:** Virtual servers in the AWS cloud. This configuration launches one EC2 instance in the public subnet and one in the private subnet.

## Resources to be Created

The following AWS resources will be created by applying this Terraform configuration:

1.  **aws\_vpc.myvpc:**
    * A VPC named "my-vpc" with the CIDR block `10.0.0.0/16`.
    * Instance tenancy set to "default".

2.  **aws\_subnet.pub-subnet:**
    * A public subnet named "my-vpc-pub-subnet" within the VPC (`
