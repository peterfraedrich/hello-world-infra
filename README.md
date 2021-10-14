# hello-world-infra

![Hello world architecture](https://github.com/peterfraedrich/hello-world-infra/blob/3668bc878472bc01a869cc5dff5b96e83ba66a43/Hello%20World%20Architecture.png?raw=true)


# Design Considerations
When designing the architecture for the Hello World app there were a few considerations that needed to be made:
* Scalability
* Common, known products and services
* Extensibility

## Scalability
The first and foremost consideration to make was in the realm of scalability. The ability to rapidly and seamlessly scale the application -- automatically, too -- is important when attempting to serve internet-scale traffic. To solve this issue on the application side, App Engine was chosen for its ability to automatically horizontally scale to meet demands. Additionally, its ease of deployment and relatively weak opinions around application deployment requirements mean that developers can be productive quickly and without having to un-learn many habits.

With regard to the database, Cloud SQL (Postgres) was chosen for its ability to scale vertically. Postgres is a high-performance RDBMS that can handle immense amounts of traffic and therefore is a perfect candidate for this application. Cloud SQL allows operators to scale the database to meet demand by increasing allocated resources (scale vertically). Additionally, Postgres is a common and known product that doesn't being licensing or vendor lock-in issues that a product like Microsoft SQL Server would. Moreover, there are a number of high-performance databases that are Postgres-compatible that could seamlessly take its place should a more high-performance database be required in the future. Cloud SQL also has the benefit of being integrated with App Engine and provides Cloud SQL Proxy by default to App Engine.

## Common, Known Products
There was a conscious attempt to avoid esoteric or unknown products that might cause unnecessary development delays or large knowledge gaps for developrs and operators alike. To a lesser extreme, products like blockchain-based databases or "pure" serverless (eg, cloud functions) offerings either didn't provide a good use case for this given problem or tend to be too opinionated to facilitate easy migration from one platform to another. In the case of App Engine, it is relatively un-opinionated in its requirements and can also accept a container as a source image, making the barrier to entry much lower than other solutions.

## Extensibility
The ability to change the architecture in meaningful ways without extensive refactoring is a key component to the long-term application lifecycle. Time spent refactoring code or pipelines for each additional change is wasted and should be avoided at all costs. In light of this, products were chosen that allow for almost independent operation and/or migration as well as the ability to layer new products on top of them. One example of this would be the addition of a CDN layer above App Engine that would allow for the caching of static assets like images, as well as the serving of those static assets from a Cloud Storage Bucket instead of out of the application itself. Introducing this extra layer would not cause significant rework and with the right planning could be implemented without any downtime. 

# Monitoring
To monitor the application it was decided to use Google Cloud's built-in monitoring solution. Like the other design considerations, this choice was made to provide the lowest barrier to entry with the greatest benefit. 

## Metrics
Overall, eight key metrics were chosen to be monitored. While all metrics should be _captured_ not all metrics should be actively monitored or alerted on. These metrics are:
* Response Time
* Connection Count
* Responses by Status Code
* App Capacity vs Utilization
* App Instance Count
* Database CPU Usage
* Database Memory Usage
* Database Transaction Rate

### Response Time
Response time is an indication of the time it takes for a given application to return data to the user. This is arguably one of the most important metrics as it dictates the user experience. Users want a fast, responsive application that does what it needs to quickly -- any delays or unnecessary slow downs in that response time will sour the user experience. Response time is the "canary metric", in that any upstream issue with the application will usually manifest in some sort of deviation from the norm with regards to response time and therefore is a good indicator of overall health. Response time should be monitored for both high and low bounds; spikes in times indicate some upstream resource is having issues serving requests, and sudden dips in times indicate that something along the way is rejecting requests without serving them. 

### Connection Count
While the number of connections to your application will naturally ebb and flow with days and times, any sudden changes in connection count are indicitive of a larger issue. Like response time, it should be monitored for both sudden spikes and sudden dips. The absolute value of your connection count doesn't matter quite as much as a response time, but the movement of that value can give you valuable data around when and how to scale or if there might be any problems between your infrastrucutre and the user.

### Responses by Status Code
Breaking out the response count by status code allows operators to make judgements about the quality of the requests being served for the users. The number of non-2xx requests climbing unexpectedly is a sure sign of issues with your application and that something needs to be looked at. This can also be computed to provide an error rate (# errors divided by the total response count).

### App Capacity vs Utilization & App Instance Count
These metrics are specific to App Engine. They show the overall capacity of App Engine to serve requests by giving the total number of instances of the application that are being run "under the hood", and also showing the resource usage overlaid on the current resource capacity. These metrics also allow you to see when and how your application is being automatically scaled by App Engine and should inform whether or not changes need to be made to that scaling policy.

### Database CPU & Memory Usage
These are basic database metrics, but they provide important insight into how your database is functioning. Traditional RDBMS databases tend to be more CPU-intensive than RAM-intensive, and as such, CPU can be a good indicator of whether or not a database needs to be scaled vertically. Setting sustained thresholds on DB CPU usage will allow operators to know when to scale a database.

### Database Transaction Rate
Much like connection count, the transaction rate is a good indicator of overall traffic. Additionally, sudden movements in connection rate indicate other more serious issues afoot in the application infrastructure. Sudden drops in transactions could mean issues with the application connecting to the database; sudden spikes in transactions could indicate that new app instances are being unncessarily rapidly spun up or that an unauthorized party is attempting to access the database.

## Application Tracing
The Hello World application itself is instrumented for operation with GCP's Tracing function, allowing us to see in real-time the status of calls made to the application.

# Future Considerations
Should the platform be iterated on, and more and greater functionality be added, there are a number of areas that are ripe for improvement.
* Security
* Caching
* Database Performance

## Security
With the application being open to the public, taking some kind fo security stance beyond simply implementing HTTPS (as is already in place) is necessary to ensure the long-term survival of the service. DDoS attempts, web page abuse (CSRF attacks, SQL injection, etc.) and other forms of application-level intrusions could be mitigated by implementing a Web Application Firewall (WAF). In conjunction with the next item -- Caching -- this would constitute a leap in security awareness and posture. But with the application such as it it is now (takes no user input, serves a single page), it was deemed unnecessary to add these features until such a time as they would become useful.

## Caching
In parallel with implementing security features, adding a caching layer in the form of a CDN has the potential to speed up page load times by caching static assets closer to the user and, with a refactor of the application, serving those static assets out of a Cloud Storage Bucket. But like with the security considerations, these features were not deemed necessary at this infant stage of the application, as the level of work required to implement them exceeded the design brief. To do this properly would require developing separate backend and front end applications and setting up custom external domains (which was out of scope for the project).

## Database Performance
While the current database consists of a single row with exactly two columns, future versions of the application may find the chosen database to be a less-than-ideal solution for the data requirements. Should this happen, a different database could be chosen. Google's BigTable has excellent performance with large data sets; Redis or Memcached provide blazing performance at the cost of features. 