resource "aws_iam_role_policy" "bastion" {
  name   = "admin_policy"
  role   = aws_iam_role.bastion.id
  policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
        {
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
    
  )
}

resource "aws_iam_role" "bastion" {
  name = "bastion-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "sts:AssumeRole"
            ],
            "Principal": {
                "Service": [
                    "ec2.amazonaws.com"
                ]
            }
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "bastion" {
  name = "bastion-role"
  role = aws_iam_role.bastion.name
}
