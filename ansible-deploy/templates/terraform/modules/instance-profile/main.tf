##################################################################################
# ec2-instance-profile
##################################################################################
resource "aws_iam_instance_profile" "this" {
  name = "${var.name}_profile"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name        = "${var.name}_role"
  path        = "/"
  description = "My ${var.name} policy"
  assume_role_policy  = "${file("${var.json_file}")}"
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = var.policy_arns
  
  role = aws_iam_role.this.id
  policy_arn = each.value
}
