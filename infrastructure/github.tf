import {
  to = rails-starter.repo
  id = "tatethurston/rails-starter"
}

import {
  to = github_branch_protection.main
  id = "tatethurston/rails-starter:main"
}

module "rails-starter" {
  source = "github.com/tatethurston/terraform-modules//modules/github?ref=main"

  name        = "rails-starter"
  description = "Opinionated Rails Starter"
  visibility  = "public"
}
