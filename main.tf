terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "2.15.0"
    }
    auth0 = {
      source  = "auth0/auth0"
      version = ">= 0.34" # Refer to docs for latest version
    }
  }

}

resource "docker_image" "terraform-secure-express" {
  name = "terraform-secure-express:1.0"
}

resource "docker_container" "terraform-secure-express" {
  image = docker_image.terraform-secure-express.latest
  name  = "terraform-secure-express"
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "AUTH0_CLIENT_ID=${auth0_client.terraform-secure-express.client_id}",
    "AUTH0_CLIENT_SECRET=${auth0_client.terraform-secure-express.client_secret}",
    "AUTH0_CLIENT_DOMAIN=${var.auth0_domain}",
    /* (5) */
    "AUTH0_API_IDENTIFIER=${var.terraform-express-api-identifier}"
  ]
}


variable "auth0_domain" {}
variable "auth0_client_id" {}
variable "auth0_client_secret" {}


provider "auth0" {
  domain        = var.auth0_domain
  client_id     = var.auth0_client_id
  client_secret = var.auth0_client_secret
}

/* https://registry.terraform.io/providers/alexkappa/auth0/latest/docs/resources/client.html#app_type */
resource "auth0_client" "terraform-secure-express" {
  name                = "Terraform Secure Express"
  description         = "App for running Dockerized Express application via Terraform"
  app_type            = "regular_web"
  callbacks           = ["http://localhost:3000/callback"]
  allowed_logout_urls = ["http://localhost:3000"]
  oidc_conformant     = true

  jwt_configuration {
    alg = "RS256"
  }
  /* (5) */
  is_first_party = true
}

//https://registry.terraform.io/providers/auth0/auth0/latest/docs/resources/connection
resource "auth0_connection" "terraform-express-user-db" {
  name     = "terraform-express-user-db"
  strategy = "auth0"
  options {
    password_policy        = "good"
    brute_force_protection = true
    /* requires_username      = true */
  }
}


variable "auth0_admin_user_password" {}

resource "auth0_user" "terraform-express-admin-user" {
  /* connection_name = auth0_connection.terraform-express-user-db.name */
  connection_name = "Username-Password-Authentication"
  user_id         = "12345"
  email           = "admin@example.com"
  email_verified  = true
  password        = var.auth0_admin_user_password
  /* (5) */
  /* roles = [auth0_role.terraform-express-admin-rolev3.id] */
}


resource "auth0_role" "admin" {
  name        = "admin"
  description = "Administrator"
}

### (5) Create an Auth0 API and Role
variable "terraform-express-api-identifier" {
  type    = string
  default = "https://terraform-express-resource-server"
}

resource "auth0_resource_server" "terraform-express-resource-server" {
  name                                            = "Terraform Auth0 Resource Server"
  identifier                                      = var.terraform-express-api-identifier
  skip_consent_for_verifiable_first_party_clients = true
  token_dialect                                   = "access_token_authz"
  enforce_policies                                = true

  scopes {
    value       = "create:note"
    description = "Only administrators can create notes"
  }

  scopes {
    value       = "read:note:self"
    description = "Read Own Notes"
  }

  scopes {
    value       = "read:note:all"
    description = "Administrators can read all notes"
  }
}

/* resource "auth0_role" "terraform-express-admin-rolev3" {
  name        = "admin"
  description = "administrator"
  permissions {
    resource_server_identifier = auth0_resource_server.terraform-express-resource-server.identifier
    name                       = "create:note"
  }

  permissions {
    resource_server_identifier = auth0_resource_server.terraform-express-resource-server.identifier
    name                       = "read:note:all"
  }
} */

## (6) Add an Auth0 Rule Using Terraform
resource "auth0_role" "terraform-express-basic-user-role" {
  name        = "basic_user"
  description = "Basic User"
  permissions {
    resource_server_identifier = auth0_resource_server.terraform-express-resource-server.identifier
    name                       = "read:note:self"
  }
}

resource "auth0_rule" "terraform-express-basic_user-rule" {
  name = "basic-user-role-assignment"
  script = templatefile("${path.module}/basic-user-rule.js", {
    TERRAFORM_ROLE_ID : auth0_role.terraform-express-basic-user-role.id
  })
  enabled = true
}