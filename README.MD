Description:

The infrastructure include 3 three components:

    1. VPC (Amazon Virtual Private Cloud) <br />
    2. EKS (Amazon Elastic Kubernetes Service) which have 2 Node EKS Managed Group , On-Demand and Spot-Instance  to optimized billing cost . <br />
    3. Amazon Aurora RDS with Multi-Region AZ replication for Autoscaling and High Availability


The EKS Cluster include components:

    1. Nginx Ingress : A reverse proxy and load balancer within Cluster
    2. Jenkins : CI/CD server  build, test, and deploy their application
    3. Metric-servers: For configuration of HorizontalPodAutoscaler, can autoscaling pod when high CPU, high traffic
    4. (Optional) Prometheus/Grafana/AlertManager : Monitoring, Alert , Observe all resrouces
    5. Fluentbit,Cloudwatch-insight-container: For ship log to CloudWatch and view log on CloudWatch


In my Assessment , I wrote myself a simple API for weather forecast and simple lambda authorizer for intergrate AWS API Gateway

Weather forecast: https://github.com/tquocthang97/demo-forecast-api
