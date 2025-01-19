provider "github" {
  token = var.github_token
}

module "rails-starter" {
  # tflint-ignore: terraform_module_pinned_source
  source = "github.com/tatethurston/terraform-modules//modules/github?ref=main"

  name        = "rails-starter"
  description = "Opinionated Rails Starter"
  visibility  = "public"
}

# TODO: Remove after import
import {
  to = module.rails-starter.github_repository.repo
  id = "rails-starter"
}

# TODO: Remove after import
import {
  to = module.rails-starter.github_branch_protection.main[0]
  id = "rails-starter:main"
}
