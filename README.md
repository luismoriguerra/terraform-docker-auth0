
## source
- https://manage.auth0.com/dashboard/us/dev-j234wyydasb1d2uw/applications


- https://auth0.com/blog/use-terraform-to-manage-your-auth0-configuration/#Adding-Terraform-Configuration
- https://manage.auth0.com/dashboard/us/dev-j234wyydasb1d2uw/applications/yVMoGzSOa8XEeW4bFmsrppO5vXPzgeiH/connections
- https://github.com/auth0/terraform-provider-auth0
- https://github.com/auth0/terraform-provider-auth0/blob/main/docs/guides/quickstart.md
- https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/user
- https://auth0.com/docs/quickstart/webapp/express
- https://github.com/auth0-blog/terraform-secure-express-example
- https://developer.hashicorp.com/terraform/cli/config/environment-variables
- https://github.com/epomatti/aws-opensearch-lambda-streaming
### envconsul

```
prefix {
    env_file = "path/to/.env"
}
```

```
brew install envconsul
envconsul -config=path/to/envconsul.hcl env terraform <your terraform command>
```

# terraform-secure-express-example

This demo contains a Node.js Express application running on Docker. It's meant to be used in conjunction with the [Auth0 Blog post about configuring Auth0 using Terraform]().

## Getting Started

```bash
$ npm install
$ docker build . -t terraform-secure-express:1.0
```

## Running the Application

### Using Docker

This app requires an Auth0 Application and API to be created. Following the [Terraform blog post]() means that these will be created by Terraform. If you wish to run the application without Terraform, you can pass your Application and API credentials into the Docker container as environment variables. Replace `{CLIENT-ID}`, `{CLIENT-SECRET}`, `{CLIENT-DOMAIN}`, and `{API-IDENTIFIER}` with your values in the following command:

```bash
$ docker run --name terraform-secure-express -p 3000:3000 --env AUTH0_CLIENT_ID={CLIENT-ID} --env AUTH0_CLIENT_SECRET={CLIENT-SECRET} --env AUTH0_CLIENT_DOMAIN={CLIENT-DOMAIN} --env AUTH0_API_IDENTIFIER={API-IDENTIFIER} terraform-secure-express:1.0
```

You can also run this app without Docker:

```bash
$ AUTH0_CLIENT_DOMAIN={CLIENT-DOMAIN} AUTH0_CLIENT_ID={CLIENT-ID} AUTH0_CLIENT_SECRET={CLIENT-SECRET} AUTH0_API_IDENTIFIER={API-IDENTIFIER} npm start
```

After running these commands, go to [http://localhost:3000](http://localhost:3000) to see the running application.



## How to test

(1) yarn deploy
(2) go to http://localhost:3000# terraform-docker-auth0
