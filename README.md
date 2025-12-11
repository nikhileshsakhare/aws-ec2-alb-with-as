# Path-Based Web Application on AWS using EC2 Auto Scaling and Application Load Balancer

This project implements a path-based web application architecture on AWS using an internet-facing Application Load Balancer (ALB), multiple EC2 Auto Scaling Groups, and Amazon Linux web servers. The ALB routes different URL paths to separate target groups and Auto Scaling Groups, each serving a specific section of the website (home, mobile, cloth).

## Architecture overview

- **Entry point**: Internet-facing Application Load Balancer (ALB) exposing a single HTTP endpoint to users.
- **Target groups**: Three instance target groups – `home-tg`, `mobile-tg`, `cloth-tg`.
- **Auto Scaling Groups**:
  - `home-as` → serves the home page.
  - `mobile-as` → serves the mobile page.
  - `cloth-as` → serves the cloth page.
- **Launch templates**:
  - `homepage`, `mobilepage`, `clothpage` each define AMI, instance type, security group, and user data.
- **VPC & subnets**: All components are deployed in the same VPC and spread across multiple subnets/Availability Zones in the Asia Pacific (Mumbai) region for high availability.

### Path-based routing

The ALB listens on HTTP port 80 and forwards traffic based on URL path.

- `/` → forwards to `home-tg` (home Auto Scaling Group).
- `/mobile/*` → forwards to `mobile-tg`.
- `/cloth/*` → forwards to `cloth-tg`.

This design allows a single DNS name to serve multiple logical applications while keeping their compute layers isolated and independently scalable.

## Skills and concepts demonstrated

- EC2 launch templates and Auto Scaling Groups for scalable web tiers.
- Application Load Balancer configuration including listeners, target groups, health checks, and path-based routing.
- User data scripts to automate Apache installation and create distinct content per service (home, mobile, cloth).
- Security group design for public web access (HTTP) and administrative SSH access.
- High availability design using multiple subnets and Availability Zones.

## Prerequisites

- AWS account with permission to create EC2 instances, Auto Scaling Groups, load balancers, security groups, and related networking resources.
- VPC with public subnets in at least two Availability Zones in the Asia Pacific (Mumbai) region (`ap-south-1`).
- A key pair for SSH access to EC2 instances (optional but recommended).

## Step 1: Create EC2 launch templates

You create three launch templates, one for each section of the site, all based on Amazon Linux 2023 and `t3.micro`.

### Common settings for all templates

- **AMI**: Amazon Linux 2023 AMI in `ap-south-1`.
- **Instance type**: `t3.micro` (free-tier eligible).
- **Security group**: `MyWebSG` allowing:
  - SSH (port 22) from your admin IP or Anywhere for lab/demo.
  - HTTP (port 80) from Anywhere for public access.

#### Security group example

- Name: `MyWebSG`.
- Inbound rules:
  - SSH, TCP 22, source `0.0.0.0/0` (lab/demo; lock down in production).
  - HTTP, TCP 80, source `0.0.0.0/0`.

### Launch templates: 

- Create it with their user data script provided and configured with the Amazon Linux 2023 AMI, `t3.micro`, and `MyWebSG`
  - `homepage`
  - `mobilepage`
  - `clothpage`

After creation, the **Launch templates** page shows `homepage`, `mobilepage`, and `clothpage` as separate templates.

## Step 2: Create Auto Scaling Groups

For each launch template, you create an Auto Scaling Group:

- **Home ASG**: `home-as` using the `homepage` template.
- **Mobile ASG**: `mobile-as` using the `mobilepage` template.
- **Cloth ASG**: `cloth-as` using the `clothpage` template.

Typical configuration:

- VPC: same VPC as the load balancer.
- Subnets: at least two public subnets in different Availability Zones.
- Desired capacity: e.g., 1–2 instances per group (lab).
- Scaling policy (optional but recommended): target-tracking policy based on average CPU utilization (e.g., target 50–60%).

This allows each section (home, mobile, cloth) to scale independently based on load.

## Step 3: Create target groups

Create three instance target groups in the same VPC, all listening on HTTP port 80.

- `home-tg`: targets the instances from `home-as`.
- `mobile-tg`: targets the instances from `mobile-as`.
- `cloth-tg`: targets the instances from `cloth-as`.

Configure health checks on HTTP port 80 and appropriate paths (for example, `/`, `/mobile/`, `/cloth/`).

## Step 4: Create Application Load Balancer

Create an internet-facing Application Load Balancer:

- Scheme: Internet-facing.
- VPC: same VPC as the Auto Scaling Groups.
- Subnets: at least two public subnets.
- Security group: `MyWebSG` or a dedicated ALB security group allowing HTTP 80 from the internet.

Listener configuration:

- **Listener**: HTTP on port 80.
- **Default action**: forward `/` traffic to `home-tg`.

Path-based rules:

- Rule 1: If path is `/mobile/*` → forward to `mobile-tg`.
- Rule 2: If path is `/cloth/*` → forward to `cloth-tg`.

Now a single ALB DNS name distributes traffic to the appropriate Auto Scaling Group based on the URL path.

## Step 5: Test the setup

- Obtain the DNS name of the ALB from the EC2 → Load Balancers page.
- In a browser:
  - `http://<ALB-DNS>` should show the home page content.
  - `http://<ALB-DNS>/mobile/` should show the mobile page content.
  - `http://<ALB-DNS>/cloth/` should show the cloth page content.
- Check target group health to ensure instances are reported as healthy.
