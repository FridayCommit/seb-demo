# For local development
# provider "github" {
#   owner = "FridayCommit"
# }

resource "github_repository" "repo" {
  name = var.repo_name
}

resource "github_repository_collaborator" "a_repo_collaborator" {
  for_each   = { for user in var.users: user.username => user }
  repository = github_repository.repo.name
  username   = each.value.username
  permission = each.value.permission
}
