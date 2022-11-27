resource "aws_ecr_repository" "match" {
 name = "match"
}

resource "aws_ecr_repository" "stress" {
  name = "stress"
}
