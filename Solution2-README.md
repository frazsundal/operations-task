## Case: Data ingestion pipeline

After reviewing data ingestion pipeline requirements, We need to consider important aspects of the pipeline are.
- Highly available
- Scalability 
- Highly Sporadic requests
- Monitoring

# Philosophy
To design such system we need to have a serverless approach which runs event driven architecture. To develop this pipeline we should take IaaC concepts which can create all these components by just a terraform script and creating new enviroment (DEV/DIT/UAT) is super easy. Serverless approach is beneficial and reduce cost and compute resource as it only runs when there is a need for the system.

# Design
---- picture
My approach to design this pipleline will start with an API gateway which is a perfect component to handle hundred of thousands of concurrent API calls with no upfront cost, You only pay for API call you receive. API Gateway provide feature such as API Version management, CORS, Auth and Access control, Throttling, Monitoring and others.

I would like to divide up coming requests in a way that all requests are divided into 2 different paths. 
POST - Request to add new batch of data goes to a lambda which will store data in S3 buckets, then a lambda will read and copy data into Amazon RDS database.
GET - Request which are trying to read data from this pipeline will go directly to a lamda function which will get data from RDS read replica database 

We have used lambda which is a perfect serverless and event driven service, its highly available and automatically scale which are two important aspect of our system. we only pay for requests served with our lambda. Lambda can use ECR image as its source which is one of the component of our system. This can help ease development in CI/CD as new code can easily be deployed.

We have divided our databases into two parts. One is our main Amazon RDS database which is used to write data, we have another read replica database which serves as caching database to improve our read calls from the API. This approach allow us to scale our system better if there is too much load on reading part we can add more replicas and if we have bottlenecks on writes part we can introduce partitioning or sharding techniques to scale our system.

AWS Cloudwatch - This is used to store all logging information coming from API Gateway, AWS Lambda and RDS database. This will help us monitor different components of the system and we can setup alerts so we know if there are any bottlenecks in our system.



# Additional questions
Here are a few possible scenarios where the system requirements change or the new functionality is required:

The batch updates have started to become very large, but the requirements for their processing time are strict.
Answer:
To be able to handle large batch of data, the best way is to introduce multi-processing and divide data into chunks which can hugely improve the reading time. Another approach is to add limit on the API to allow specific data chunk in each request, to be fair all big APIs provider have some sort of limitations and throttling built into their API to handle load on the system.

Code updates need to be pushed out frequently. This needs to be done without the risk of stopping a data update already being processed, nor a data response being lost.
Answer:
If we use Amazon code deploy with AWS serverless application model and then we can control the deployment to live lambda using AutoPublishAlias. This will allow creating new aliases and start using new version of your code.

For development and staging purposes, you need to start up a number of scaled-down versions of the system.
Answer:
If we are using a scale down version of the system, we could easily have smaller instance of our application such as RDS database could utilize small instance class and we dont have to provide multiple AZ regions. API gateway and Lambda only cost us when its been used. These settings can be set while creating terraform script for lower environments. 

Please address at least one of the situations. Please describe:

Which parts of the system are the bottlenecks or problems that might make it incompatible with the new requirements?
How would you restructure and scale the system to address those?

Answer:
If we have big data requirements, I think we need to introduce data processing framework such as Apache Spark which have powerful compute and can process TB of data very easily





